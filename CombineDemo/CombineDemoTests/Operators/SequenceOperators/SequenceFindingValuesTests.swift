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
}
