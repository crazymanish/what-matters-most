//
//  MeasureTimeTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 16/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `measureInterval(using:options:)` Measures and emits the time interval between events received from an upstream publisher.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/measureinterval(using:options:)
/// - Use measureInterval(using:options:) to measure the time between events delivered from an upstream publisher.
final class MeasureTimeTests: XCTestCase {
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

    func testPublisherWithMeasureTimeOperator() {
        let expectation = XCTestExpectation(description: "Testing measure time strategy operator")

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

        let typingHelloWorldPublisher = PassthroughSubject<String, Never>()
        var receivedValues: [String] = []

        typingHelloWorldPublisher
            .measureInterval(using: RunLoop.main)
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true

                expectation.fulfill()
            }
        } receiveValue: { value in
            print("RunLoop.SchedulerTimeType.Stride : \(value)")

            let timeInterval = String(format: "%.2f", value.magnitude) // Double(value.magnitude) / 1_000_000_000.0
            receivedValues.append(timeInterval)
        }
        .store(in: &cancellables)

        // Sending typingHelloWorldPublisher values after continuous TimeInterval
        for (key, value) in typingHelloWorld {
            DispatchQueue.main.asyncAfter(deadline: .now() + key) {
                typingHelloWorldPublisher.send(value)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Sending finished for typingHelloWorldPublisher
            typingHelloWorldPublisher.send(completion: .finished)

            // Time interval of each received values
            XCTAssertEqual(receivedValues, ["0.00", "0.21", "0.32", "3.54", "0.10", "0.10", "0.20", "0.10"])

            XCTAssertTrue(self.isFinishedCalled) // typingHelloWorldPublisher is also finished
        }

        wait(for: [expectation], timeout: 10.0)
    }
}
