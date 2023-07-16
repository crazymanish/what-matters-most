//
//  DebounceTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 16/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `debounce(for:scheduler:options:)` Publishes elements only after a specified time interval elapses between events.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/debounce(for:scheduler:options:)
/// - Use the debounce(for:scheduler:options:) operator to control the number of values and time between delivery of values from the upstream publisher.
/// - This operator is useful to process bursty or high-volume event streams where you need to reduce the number of values delivered to the downstream to a rate you specify.
///
/// - For example, you may want to send a search URL request that returns a list of items matching what’s typed in the text field.
/// - But of course, you don’t want to send a request every time your user types a single letter! You need some kind of mechanism to help pick up on typed text only when the user is done typing for a while.
/// - Combine offers two operators that can help you here: debounce and throttle.
final class DebounceTests: XCTestCase {
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

    func testPublisherWithDebounceOperator() {
        let expectation = XCTestExpectation(description: "Testing debounce with time strategy operator")

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
        let debouncedPublisher = continuousPublisher.debounce(for: .seconds(1.0), scheduler: DispatchQueue.main) // debounce will kick-in after one second pause of continuousPublisher

        var isContinuousPublisherFinishedCalled = false
        var receivedDebouncedValues: [String] = []

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

        debouncedPublisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            print("debouncedPublisher : \(value)")
            receivedDebouncedValues.append(value)
        }
        .store(in: &cancellables)

        // Sending continuousPublisher values after continuous TimeInterval
        for (key, value) in typingHelloWorld {
            DispatchQueue.main.asyncAfter(deadline: .now() + key) {
                continuousPublisher.send(value)
            }
        }

        /*
         +0.0s: continuousPublisher emitted: H
         +0.1s: continuousPublisher emitted: He
         +0.2s: continuousPublisher emitted: Hel
         +0.3s: continuousPublisher emitted: Hell
         +0.5s: continuousPublisher emitted: Hello
         +0.6s: continuousPublisher emitted: Hello
         +1.6s: debouncedPublisher emitted: Hello  // 👀
         +2.1s: continuousPublisher emitted: Hello W
         +2.1s: continuousPublisher emitted: Hello Wo
         +2.4s: continuousPublisher emitted: Hello Wor
         +2.4s: continuousPublisher emitted: Hello Worl
         +2.7s: continuousPublisher emitted: Hello World
         +3.7s: debouncedPublisher emitted: Hello World // 👀

         As you can see, at 0.6 seconds the user pauses and resumes typing only at 2.1 seconds.
         Meanwhile, you configured debounce to wait for a one-second pause. It obliges (at 1.6 seconds) and emits the latest received value.
         Same around the end where typing ends at 2.7 seconds and debounce kicks in one second later at 3.7 seconds. Cool!
         */

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Sending finished for continuousPublisher
            continuousPublisher.send(completion: .finished)

            // Ensuring that only received debounced values, instead of all continuous values
            XCTAssertEqual(receivedDebouncedValues, ["Hello ", "Hello World"])

            XCTAssertTrue(isContinuousPublisherFinishedCalled) // continuousPublisher is finished
            XCTAssertFalse(self.isFinishedCalled) // debouncedPublisher is not yet finished
        }

        wait(for: [expectation], timeout: 10.0)
    }
}
