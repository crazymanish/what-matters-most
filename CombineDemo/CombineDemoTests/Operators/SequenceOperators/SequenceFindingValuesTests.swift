//
//  SequenceFindingValuesTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 05/08/2023.
//

import Foundation
import Combine
import XCTest

/*
 Sequence operators
 - Sequence operators are easiest to understand when you realize that publishers are just sequences themselves.
 - Sequence operators work with the `collection of a publisher’s values`, much like an array or set — which, of course, are just finite sequences!

 Finding values
 - This file consists of operators that locate specific values the publisher emits based on different criteria.
 - These are similar to the collection methods in the Swift standard library.

 - `min()` Publishes the minimum value received from the upstream publisher, after it finishes.
 - https://developer.apple.com/documentation/combine/publishers/reduce/min()

 - `min(by:)` Publishes the minimum value received from the upstream publisher, after it finishes.
 - A closure that receives two elements and returns true if they’re in increasing order.
 - https://developer.apple.com/documentation/combine/publishers/reduce/min(by:)

 - `max()` Publishes the maximum value received from the upstream publisher, after it finishes.
 - https://developer.apple.com/documentation/combine/publishers/reduce/max()
 */
final class SequenceFindingValuesTests: XCTestCase {
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

    func testPublisherWithMinOperator() {
        // Given: Publisher
        let publisher = [15, -1, 10, 5].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .min() // Returns the minimum value, after upstream will finish!
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            receivedValues.append(value)
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [-1])
    }

    func testPublisherWithMinByOperator() {
        // Given: Publisher
        let publisher = [
            "12345",
            "ab",
            "hello world"
        ]
            .compactMap { $0.data(using: .utf8) } // [Data]
            .publisher // Publisher<Data, Never>

        var receivedValues: [String] = []

        // When: Sink(Subscription)
        // Data doesn't conform to Comparable, that's why using the min(by:) operator to find the Data-object with the smallest number of bytes.
        // The publisher emits all its Data objects and finishes, then min(by:) finds and emits the data with the smallest byte size and sink receives it.
        publisher
            .min(by: { $0.count < $1.count }) // Returns the minimum value (based on Data-bytes count), after upstream will finish!
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            let stringValue = String(data: value, encoding: .utf8)!
            receivedValues.append(stringValue)
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, ["ab"])
    }

    func testPublisherWithMaxOperator() {
        // Given: Publisher
        let publisher = [5, -1, 10, 5].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .max() // Returns the maximum value, after upstream will finish!
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            receivedValues.append(value)
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [10])
    }
}
