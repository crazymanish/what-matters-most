//
//  ThrottleTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 16/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `throttle(for:scheduler:latest:)` Publishes either the most-recent or first element published by the upstream publisher in the specified time interval.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/throttle(for:scheduler:latest:)
/// - Use throttle(for:scheduler:latest:) to selectively republish elements from an upstream publisher during an interval you specify. Other elements received from the upstream in the throttling interval aren’t republished.
///
/// - For example, you may want to send a search URL request that returns a list of items matching what’s typed in the text field.
/// - But of course, you don’t want to send a request every time your user types a single letter! You need some kind of mechanism to help pick up on typed text only when the user is done typing for a while.
/// - Combine offers two operators that can help you here: debounce and throttle.
final class ThrottleTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil

        super.tearDown()
    }

    func testPublisherWithThrottleOperatorWithLatestValueAsFalse() {
        let expectation = XCTestExpectation(description: "Testing throttle with time strategy operator")

        let typingHelloWorld: [(TimeInterval, String)] = [
            (0.0, "H"),
            (0.1, "He"),
            (0.2, "Hel"),
            (0.3, "Hell"),
            (0.5, "Hello"),
            (0.6, "Hello "),
            (2.0, "Hello W"), // The simulated user starts typing at 0.0 seconds, pauses after 0.6 seconds, and resumes typing at 2.0 seconds.
            (2.1, "Hello Wo"),
            (2.2, "Hello Wor"),
            (2.4, "Hello Worl"),
            (2.5, "Hello World")
          ]

        let continuousPublisher = PassthroughSubject<String, Never>()
        // throttle will kick-in after one second pause of continuousPublisher
        let throttledPublisher = continuousPublisher.throttle(for: .seconds(1.0), scheduler: DispatchQueue.main, latest: false) // latest value is false

        var isContinuousPublisherFinishedCalled = false
        var receivedThrottledPublisherValues: [String] = []

        continuousPublisher.sink { completion in
            switch completion {
            case .finished:
                isContinuousPublisherFinishedCalled = true
                expectation.fulfill()
            }
        } receiveValue: { value in
            print("continuousPublisher : \(value)")
        }
        .store(in: &cancellables)

        throttledPublisher
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            print("throttledPublisher : \(value)")
            receivedThrottledPublisherValues.append(value)
        }
        .store(in: &cancellables)

        // Sending continuousPublisher values after continuous TimeInterval
        for (key, value) in typingHelloWorld {
            DispatchQueue.main.asyncAfter(deadline: .now() + key) {
                continuousPublisher.send(value)
            }
        }

        /*
         0.0: continuousPublisher : H
         ✅0.0: throttledPublisher : H // 👀
         0.1: continuousPublisher : He
         0.2: continuousPublisher : Hel
         0.3: continuousPublisher : Hell
         0.5: continuousPublisher : Hello
         0.6: continuousPublisher : Hello
         ✅1.0: throttledPublisher : He // Not using latest(last)-value as mentioned above 👀
         2.0: continuousPublisher : Hello W
         ✅2.0: throttledPublisher : Hello W // 👀
         2.1: continuousPublisher : Hello Wo
         2.2: continuousPublisher : Hello Wor
         2.4: continuousPublisher : Hello Worl
         2.5: continuousPublisher : Hello World
         ✅3.0: throttledPublisher : Hello Wo // Not using latest(last)-value as mentioned above 👀
         */

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Sending finished for continuousPublisher
            continuousPublisher.send(completion: .finished)

            // Ensuring that only received throttled values, instead of all continuous values
            XCTAssertEqual(receivedThrottledPublisherValues, ["H", "He", "Hello W", "Hello Wo"])

            XCTAssertTrue(isContinuousPublisherFinishedCalled) // continuousPublisher is finished
            XCTAssertFalse(self.isFinishedCalled) // throttledPublisher is not yet finished
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testPublisherWithThrottleOperatorWithLatestValueAsTrue() {
        let expectation = XCTestExpectation(description: "Testing throttle with time strategy operator scenario2")

        let typingHelloWorld: [(TimeInterval, String)] = [
            (0.0, "H"),
            (0.1, "He"),
            (0.2, "Hel"),
            (0.3, "Hell"),
            (0.5, "Hello"),
            (0.6, "Hello "),
            (2.0, "Hello W"), // The simulated user starts typing at 0.0 seconds, pauses after 0.6 seconds, and resumes typing at 2.0 seconds.
            (2.1, "Hello Wo"),
            (2.2, "Hello Wor"),
            (2.4, "Hello Worl"),
            (2.5, "Hello World")
          ]

        let continuousPublisher = PassthroughSubject<String, Never>()
        // throttle will kick-in after one second pause of continuousPublisher
        let throttledPublisher = continuousPublisher.throttle(for: .seconds(1.0), scheduler: DispatchQueue.main, latest: true) // latest value is true

        var isContinuousPublisherFinishedCalled = false
        var receivedThrottledPublisherValues: [String] = []

        continuousPublisher.sink { completion in
            switch completion {
            case .finished:
                isContinuousPublisherFinishedCalled = true
                expectation.fulfill()
            }
        } receiveValue: { value in
            print("continuousPublisher : \(value)")
        }
        .store(in: &cancellables)

        throttledPublisher
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            print("throttledPublisher : \(value)")
            receivedThrottledPublisherValues.append(value)
        }
        .store(in: &cancellables)

        // Sending continuousPublisher values after continuous TimeInterval
        for (key, value) in typingHelloWorld {
            DispatchQueue.main.asyncAfter(deadline: .now() + key) {
                continuousPublisher.send(value)
            }
        }

        /*
         0.0: continuousPublisher : H
         ✅0.0: throttledPublisher : H // latest(last)-value as mentioned above 👀
         0.1: continuousPublisher : He
         0.2: continuousPublisher : Hel
         0.3: continuousPublisher : Hell
         0.5: continuousPublisher : Hello
         0.6: continuousPublisher : Hello
         ✅1.0: throttledPublisher : Hello // latest(last)-value as mentioned above 👀 (debounce would have kicks-in at 1.6, instead of 1.0)
         2.0: continuousPublisher : Hello W
         ✅2.0: throttledPublisher : Hello W // latest(last)-value as mentioned above 👀 (debounce would have not kicks-in here because user is keep typing!)
         2.1: continuousPublisher : Hello Wo
         2.2: continuousPublisher : Hello Wor
         2.4: continuousPublisher : Hello Worl
         2.5: continuousPublisher : Hello World
         ✅3.0: throttledPublisher : Hello World // latest(last)-value as mentioned above 👀 (debounce would have kicks-in at 3.5, instead of 3.0)
         */

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Sending finished for continuousPublisher
            continuousPublisher.send(completion: .finished)

            // Ensuring that only received throttled values, instead of all continuous values
            XCTAssertEqual(receivedThrottledPublisherValues, ["H", "Hello ", "Hello W", "Hello World"])

            XCTAssertTrue(isContinuousPublisherFinishedCalled) // continuousPublisher is finished
            XCTAssertFalse(self.isFinishedCalled) // throttledPublisher is not yet finished
        }

        wait(for: [expectation], timeout: 10.0)
    }
}
