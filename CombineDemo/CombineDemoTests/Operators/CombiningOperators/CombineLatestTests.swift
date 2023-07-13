//
//  CombineLatestTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 13/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `combineLatest(_:_:)` Subscribes to an additional publisher and invokes a closure upon receiving output from either publisher.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/combinelatest(_:_:)-65rrl
/// - Tip: The combined publisher doesn’t produce elements until each of its upstream publishers publishes at least one element.
///
/// - Use combineLatest<P,T>(_:) to combine the current and one additional publisher and transform them using a closure you specify to publish a new value to the downstream.
/// - The combined publisher passes through any requests to all upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t .unlimited, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most-recent value in each buffer.
/// - In the example below, combineLatest() receives the most-recent values published by the two publishers, it multiplies them together, and republishes the result:
final class CombineLatestTests: XCTestCase {
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

    func testPublisherWithSwitchToLatestOperator() {
        // Given: Publishers
        // Create two PassthroughSubjects. The first accepts integers with no errors, while the second accepts strings with no errors.
        let publisher1 = PassthroughSubject<Int, Never>()
        let publisher2 = PassthroughSubject<String, Never>()

        var receivedValues: [String] = []

        // When: Sink(Subscription)
        // Combine the latest emissions of publisher2 with publisher1. You may combine up to four different publishers using different overloads of combineLatest.
        publisher1
            .combineLatest(publisher2) // Combining the latest Publisher's value
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { p1IntValue, p2StringValue in
            let combinedValue = String(p1IntValue) + ":" + p2StringValue // combining here
            receivedValues.append(combinedValue)
        }
        .store(in: &cancellables)

        // Sending publisher's value

        // Send 1 and 2 to publisher1,
        publisher1.send(1) // Ignored: The combined publisher doesn’t produce elements until each of its upstream publishers publishes at least one element.
        publisher1.send(2)

        // Send "a" and "b" to publisher2,
        publisher2.send("a")
        publisher2.send("b")

        // Send 3 to publisher1
        publisher1.send(3)

        // and finally Send "c" to publisher2.
        publisher2.send("c")

        // Finally, you send a completion event to the current publisher1, publisher2,
        // This completes all active subscriptions.
        publisher1.send(completion: .finished)
        publisher2.send(completion: .finished)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, ["2:a", "2:b", "3:b", "3:c"]) // Received combineLatest values
    }
}
