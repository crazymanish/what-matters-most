//
//  ZipTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 13/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `zip(_:)`Combines elements from another publisher and deliver pairs of elements as tuples.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/zip(_:)
///
/// - Use zip(_:) to combine the latest elements from two publishers and emit a tuple to the downstream. The returned publisher waits until both publishers have emitted an event, then delivers the oldest unconsumed event from each publisher together as a tuple to the subscriber.
/// - Much like a zipper or zip fastener on a piece of clothing pulls together rows of teeth to link the two sides, zip(_:) combines streams from two different publishers by linking pairs of elements from each side.
/// - In this example, numbers and letters are PassthroughSubjects that emit values; once zip(_:) receives one value from each, it publishes the pair as a tuple to the downstream subscriber. It then waits for the next pair of values.
///
/// - You might recognize this one from the Swift standard library method with the same name on Sequence types.
/// - This operator works similarly, emitting tuples of paired values in the same indexes. It waits for each publisher to emit an item, then emits a single tuple of items after all publishers have emitted an value at the current index.
/// - This means that if you are zipping two publishers, you’ll get a single tuple emitted every time both publishers emit a value.
final class ZipTests: XCTestCase {
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

    func testPublisherWithZipOperator() {
        // Given: Publishers
        // Create two PassthroughSubjects. The first accepts integers with no errors, while the second accepts strings with no errors.
        let publisher1 = PassthroughSubject<Int, Never>()
        let publisher2 = PassthroughSubject<String, Never>()

        var receivedValues: [String] = []

        // When: Sink(Subscription)
        publisher1
            .zip(publisher2) // zipping publisher2
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { p1IntValue, p2StringValue in
            let combinedValue = String(p1IntValue) + ":" + p2StringValue // combining zipping values
            receivedValues.append(combinedValue)
        }
        .store(in: &cancellables)

        // Sending publisher's value

        // Send 1 and 2 to publisher1,
        publisher1.send(1)
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
        XCTAssertEqual(receivedValues, ["1:a", "2:b", "3:c"]) // Received zipped values
    }
}
