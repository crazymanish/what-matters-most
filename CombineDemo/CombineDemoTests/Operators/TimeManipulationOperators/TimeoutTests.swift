//
//  TimeoutTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 16/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `timeout(_:scheduler:options:customError:)` Terminates publishing if the upstream publisher exceeds the specified time interval without producing an element.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/timeout(_:scheduler:options:customerror:)
/// - Use timeout(_:scheduler:options:customError:) to terminate a publisher if an element isn’t delivered within a timeout interval you specify.
final class TimeoutTests: XCTestCase {
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

    func testPublisherWithTimeoutOperatorWithSuccess() {
        let expectation = XCTestExpectation(description: "Testing timeout-with-success with time strategy operator")

        let typingHelloWorld: [(TimeInterval, String)] = [
            (0.0, "H"),
            (0.2, "Hel"),
            (0.5, "Hello"),
            (4.0, "Hello W"), // The simulated user starts typing at 0.0 seconds, pauses after 0.6 seconds, and resumes typing at 4.0 seconds.
            (4.1, "Hello Wo"),
            (4.2, "Hello Wor"),
            (4.4, "Hello Worl"),
            (4.5, "Hello World")
          ]

        let continuousPublisher = PassthroughSubject<String, Never>()
        let timeoutPublisher = continuousPublisher.timeout(.seconds(2.0), scheduler: DispatchQueue.main, options: nil, customError: nil) // Timeout after 2 seconds

        var isContinuousPublisherFinishedCalled = false
        var receivedValues: [String] = []

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

        timeoutPublisher
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            print("timeoutPublisher : \(value)")
            receivedValues.append(value)
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
         0.0: timeoutPublisher : H // 👀
         0.2: continuousPublisher : Hel
         0.2: timeoutPublisher : Hel // 👀
         0.5: continuousPublisher : Hello
         0.5: timeoutPublisher : Hello // 👀
         4.0: continuousPublisher : Hello W // TimeOut is already kicks-in with success because difference b/w (4.0 - 0.5) > 2 seconds and no longer accepting new values
         4.1: continuousPublisher : Hello Wo
         4.2: continuousPublisher : Hello Wor
         4.4: continuousPublisher : Hello Worl
         4.5: continuousPublisher : Hello World
         */

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Sending finished for continuousPublisher
            continuousPublisher.send(completion: .finished)

            // Ensuring that only received all values before timeout, instead of all continuous values after timeout
            XCTAssertEqual(receivedValues, ["H", "Hel", "Hello"])

            XCTAssertTrue(isContinuousPublisherFinishedCalled) // continuousPublisher is finished
            XCTAssertTrue(self.isFinishedCalled) // timeoutPublisher is also finished
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testPublisherWithTimeoutOperatorWithError() {
        let expectation = XCTestExpectation(description: "Testing timeout-with-error with time strategy operator")

        let typingHelloWorld: [(TimeInterval, String)] = [
            (0.0, "H"),
            (0.2, "Hel"),
            (0.5, "Hello"),
            (4.0, "Hello W"), // The simulated user starts typing at 0.0 seconds, pauses after 0.6 seconds, and resumes typing at 4.0 seconds.
            (4.1, "Hello Wo"),
            (4.2, "Hello Wor"),
            (4.4, "Hello Worl"),
            (4.5, "Hello World")
          ]

        let continuousPublisher = PassthroughSubject<String, Never>()
        let error = ApiError(code: .notFound)
        let timeoutPublisher = continuousPublisher
            .setFailureType(to: ApiError.self)
            .timeout(.seconds(2.0), scheduler: DispatchQueue.main, options: nil, customError: { error } ) // Timeout after 2 seconds with ApiError

        var isContinuousPublisherFinishedCalled = false
        var receivedValues: [String] = []
        var receivedError: ApiError?

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

        timeoutPublisher
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            case .failure(let error):
                receivedError = error
            }
        } receiveValue: { value in
            print("timeoutPublisher : \(value)")
            receivedValues.append(value)
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
         0.0: timeoutPublisher : H // 👀
         0.2: continuousPublisher : Hel
         0.2: timeoutPublisher : Hel // 👀
         0.5: continuousPublisher : Hello
         0.5: timeoutPublisher : Hello // 👀
         4.0: continuousPublisher : Hello W // TimeOut is already kicks-in with ERROR because difference b/w (4.0 - 0.5) > 2 seconds and no longer accepting new values
         4.1: continuousPublisher : Hello Wo
         4.2: continuousPublisher : Hello Wor
         4.4: continuousPublisher : Hello Worl
         4.5: continuousPublisher : Hello World
         */

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Sending finished for continuousPublisher
            continuousPublisher.send(completion: .finished)

            // Ensuring that only received all values before timeout, instead of all continuous values after timeout
            XCTAssertEqual(receivedValues, ["H", "Hel", "Hello"])

            XCTAssertTrue(isContinuousPublisherFinishedCalled) // continuousPublisher is finished
            XCTAssertFalse(self.isFinishedCalled) // timeoutPublisher finished is not called because it got timeout with ERROR
            XCTAssertEqual(receivedError?.code, .notFound) // timeoutPublisher finished with correct ERROR
        }

        wait(for: [expectation], timeout: 10.0)
    }
}
