//
//  SequenceQueryingValuesTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 06/08/2023.
//

import Foundation
import Combine
import XCTest

/*
 Sequence operators
 - Sequence operators are easiest to understand when you realize that publishers are just sequences themselves.
 - Sequence operators work with the `collection of a publisher’s values`, much like an array or set — which, of course, are just finite sequences!

 Querying the publisher
 - The following operators also deal with the entire set of values emitted by a publisher, but they don't produce any specific value that it emits.
 - Instead, these operators emit a different value representing some query on the publisher as a whole. A good example of this is the count operator.

 - `count()` Publishes the number of elements received from the upstream publisher.
 - https://developer.apple.com/documentation/combine/publishers/reduce/count()

 - `contains(_:)` Publishes a Boolean value upon receiving an element equal to the argument.
 - The contains publisher consumes all received elements until the upstream publisher produces a matching element. Upon finding the first match, it emits true and finishes normally. If the upstream finishes normally without producing a matching element, this publisher emits false and finishes.
 - https://developer.apple.com/documentation/combine/publishers/reduce/contains(_:)

 - `contains(where:)` Publishes a Boolean value upon receiving an element that satisfies the predicate closure.
 - Param: A closure that takes an element as its parameter and returns a Boolean value that indicates whether the element satisfies the closure’s comparison logic.
 - Use contains(where:) to find the first element in an upstream that satisfies the closure you provide. This operator consumes elements produced from the upstream publisher until the upstream publisher produces a matching element.
 - This operator is useful when the upstream publisher produces elements that don’t conform to Equatable.
 - https://developer.apple.com/documentation/combine/publishers/reduce/contains(where:)

 - `allSatisfy(_:)` Publishes a single Boolean value that indicates whether all received elements pass a given predicate.
 - Param: A closure that evaluates each received element. Return true to continue, or false to cancel the upstream and complete.
 - Use the allSatisfy(_:) operator to determine if all elements in a stream satisfy a criteria you provide.
 - When this publisher receives an element, it runs the predicate against the element. If the predicate returns false, the publisher produces a false value and finishes.
 - If the upstream publisher finishes normally, this publisher produces a true value and finishes.
 - https://developer.apple.com/documentation/combine/publishers/reduce/allsatisfy(_:)
 */
final class SequenceQueryingValuesTests: XCTestCase {
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

    func testPublisherWithCountOperator() {
        // Given: Publisher
        let publisher = [15, -1, 10, 5].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .count() // Returns the count value, after upstream will finish!
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
        XCTAssertEqual(receivedValues, [4])
    }

    func testPublisherWithContainsOperator() {
        // Given: Publisher
        let publisher = [15, -1, 10, 5].publisher
        var receivedValues: [Bool] = []

        // When: Sink(Subscription)
        // You might have also noticed contains is lazy, as it only consumes as many upstream values as it needs to perform its work.
        // Once 10 is found, it cancels the subscription and doesn't produce any further values.
        publisher
            .contains(10) // Emits the Boolean value true when the upstream publisher emits a matching value (10).
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
        XCTAssertEqual(receivedValues, [true])
    }

    func testPublisherWithContainsWhereOperator() {
        // Given: Publisher
        let publisher = [2, -1, 10, 5].publisher
        var receivedValues: [Bool] = []

        // When: Sink(Subscription)
        publisher
            .contains {$0 > 4} // emits true for the first elements that’s greater than 4, and then finishes normally.
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
        XCTAssertEqual(receivedValues, [true])
    }

    func testPublisherWithAllSatisfyOperator() {
        // Given: Publisher
        let targetRange = (-1...100)
        let publisher = [2, -1, 10, 5].publisher
        var receivedValues: [Bool] = []

        // When: Sink(Subscription)
        publisher
            .allSatisfy { targetRange.contains($0) } // emits true if each an integer array publisher’s elements fall into the targetRange:
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
        XCTAssertEqual(receivedValues, [true])
    }
}
