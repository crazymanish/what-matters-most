//
//  ShiftingTimeTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 15/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `delay(for:tolerance:scheduler:options:)` Delays delivery of all output to the downstream receiver by a specified amount of time on a particular scheduler.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/delay(for:tolerance:scheduler:options:)
///
/// - Use delay(for:tolerance:scheduler:options:) when you need to delay the delivery of elements to a downstream by a specified amount of time.
/// - In this example, a Timer publishes an event every second. The delay(for:tolerance:scheduler:options:) operator holds the delivery of the initial element for 3 seconds (±0.5 seconds), after which each element is delivered to the downstream on the main run loop after the specified delay:
final class ShiftingTimeTests: XCTestCase {
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

    func testPublisherWithDelayOperator() {
        let expectation = XCTestExpectation(description: "Testing delay operator")

        var sentValues: [String] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .long

        Timer.publish(every: 1.0, on: .main, in: .default)
            .autoconnect()
            .handleEvents(receiveOutput: { date in
                let dateTimeValue = (dateFormatter.string(from: date))
                sentValues.append(dateTimeValue)
            })
            .delay(for: .seconds(3), scheduler: RunLoop.main, options: .none)
            .collect(2)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true
                }
            } receiveValue: { values in
                let now = Date()

                for (index, value) in values.enumerated() {
                    let receivedDateTimeValue = dateFormatter.string(from: value)
                    let receivedValueAfterDelay = String(format: "%.0f", now.timeIntervalSince(value))

                    XCTAssertEqual(receivedDateTimeValue, sentValues[index]) // Received correct values in exactly same order after delay
                    XCTAssertEqual(receivedValueAfterDelay, "\(4-index)") // Received after correct delay (diff is always 1 second because above Timer is publishing new value in every second)
                }

                expectation.fulfill()
            }
            .store(in: &cancellables)

        XCTAssertFalse(isFinishedCalled) // Timer is not finished

        wait(for: [expectation], timeout: 10.0)
    }
}

