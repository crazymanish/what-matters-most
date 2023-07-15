//
//  CollectByTimeTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 15/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `collect(_:options:)` Collects elements by a given time-grouping strategy, and emits a single array of the collection.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/collect(_:options:)
/// - Use collect(_:options:) to emit arrays of elements on a schedule specified by a Scheduler and Stride that you provide. At the end of each scheduled interval, the publisher sends an array that contains the items it collected.
/// - If the upstream publisher finishes before filling the buffer, the publisher sends an array that contains items it received. This may be fewer than the number of elements specified in the requested Stride.

/// - If the upstream publisher fails with an error, this publisher forwards the error to the downstream receiver instead of sending its output.
final class CollectByTimeTests: XCTestCase {
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

    func testPublisherWithCollectByTimeOperator() {
        let expectation = XCTestExpectation(description: "Testing collect with time strategy operator")

        var sentValues: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .long

        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .handleEvents(receiveOutput: { date in
                let dateTimeValue = (dateFormatter.string(from: date))
                sentValues.append(dateTimeValue)
            })
            .collect(.byTime(DispatchQueue.main, .seconds(4))) // Collecting value
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true
                }
            } receiveValue: { values in
                print(sentValues) // Sent values
                print("--------------")
                print(values.map { dateFormatter.string(from: $0) }) // received values

                for (index, value) in values.enumerated() {
                    let receivedDateTimeValue = dateFormatter.string(from: value)

                    XCTAssertEqual(receivedDateTimeValue, sentValues[index]) // Received correct values in exactly same order after delay
                }

                expectation.fulfill()
            }
            .store(in: &cancellables)

        XCTAssertFalse(isFinishedCalled) // Timer is not finished

        wait(for: [expectation], timeout: 10.0)
    }
}
