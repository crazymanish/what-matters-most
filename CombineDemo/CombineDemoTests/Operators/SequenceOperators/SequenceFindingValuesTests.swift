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

 - `max(by:)` Publishes the maximum value received from the upstream publisher, using the provided ordering closure.
 - A closure that receives two elements and returns true if they’re in increasing order.
 - https://developer.apple.com/documentation/combine/publishers/reduce/max(by:)

 - `first()` Publishes the first element of a stream, then finishes.
 - https://developer.apple.com/documentation/combine/publishers/reduce/first()

 - `first(where:)` Publishes the first element of a stream to satisfy a predicate closure, then finishes normally.
 - A closure that takes an element as a parameter and returns a Boolean value that indicates whether to publish the element.
 - https://developer.apple.com/documentation/combine/publishers/reduce/first(where:)

 - `last()` Publishes the last element of a stream, after the stream finishes.
 - https://developer.apple.com/documentation/combine/publishers/reduce/last()
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

    func testPublisherWithMaxByOperator() {
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
        // Data doesn't conform to Comparable, that's why using the max(by:) operator to find the Data-object with the largest number of bytes.
        // The publisher emits all its Data objects and finishes, then max(by:) finds and emits the data with the largest byte size and sink receives it.
        publisher
            .max(by: { $0.count < $1.count }) // Returns the maximum value (based on Data-bytes count), after upstream will finish!
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
        XCTAssertEqual(receivedValues, ["hello world"])
    }

    func testPublisherWithFirstOperator() {
        // Given: Publisher
        let publisher = [15, -1, 10, 5].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .first() // `first()` publish just the first element from an upstream publisher, then finish normally.
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
        XCTAssertEqual(receivedValues, [15])
    }

    func testPublisherWithFirstWhereOperator() {
        // Given: Publisher
        let publisher = [15, -1, 10, 5].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .first { $0 < 0 } // `first(where:)` publish only the first element of a stream that satisfies a closure specify, then finish normally.
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

    func testPublisherWithLastOperator() {
        // Given: Publisher
        let publisher = [15, -1, 10, 5].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .last() // `last()` publish only the last element from an upstream publisher., then finish normally.
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
        XCTAssertEqual(receivedValues, [5])
    }
}
