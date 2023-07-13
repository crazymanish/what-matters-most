//
//  SwitchToLatestTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 13/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `switchToLatest()` Republishes elements sent by the most recently received publisher.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/switchtolatest()
/// - This operator works with an upstream publisher of publishers, flattening the stream of elements to appear as if they were coming from a single stream of elements. It switches the inner publisher as new ones arrive but keeps the outer publisher constant for downstream subscribers.
/// - When this operator receives a new publisher from the upstream publisher, it cancels its previous subscription. Use this feature to prevent earlier publishers from performing unnecessary work, such as creating network request publishers from frequently updating user interface publishers.
///
/// - If you’re not sure why this is useful in a real-life app, consider the following scenario:
/// - Your user taps a button that triggers a network request. Immediately afterward, the user taps the button again, which triggers a second network request. But how do you get rid of the pending request, and only use the latest request? switchToLatest to the rescue!
final class SwitchToLatestTests: XCTestCase {
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
        // Create three PassthroughSubjects that accept integers and no errors.
        let publisher1 = PassthroughSubject<Int, Never>()
        let publisher2 = PassthroughSubject<Int, Never>()
        let publisher3 = PassthroughSubject<Int, Never>()

        // Publisher of publishers
        // Create a second PassthroughSubject that accepts other PassthroughSubjects.
        // For example, you can send publisher1, publisher2 or publisher3 through it.
        let publishers = PassthroughSubject<PassthroughSubject<Int,Never>, Never>()

        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publishers
            .switchToLatest() // Switching to latest Publisher
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            receivedValues.append(value)
        }
        .store(in: &cancellables)

        // Sending publisher's value

        // Send publisher1 to publishers and then send value 1 and 2 to publisher1.
        publishers.send(publisher1)
        publisher1.send(1)
        publisher1.send(2)

        // Send publisher2, which cancels the subscription to publisher1.
        // You then send 3 to publisher1, but it’s ignored,
        // and send 4 and 5 to publisher2, which are pushed through because publisher2 is the current subscription.
        publishers.send(publisher2)
        publisher1.send(3) // this will be ignored (switchToLatest will allow publisher2 value only)
        publisher2.send(4)
        publisher2.send(5)

        // Send publisher3, which cancels the subscription to publisher2.
        // As above, you send 6 to publisher2 and it’s ignored,
        // and then send 7, 8 and 9, which are pushed through the subscription.
        publishers.send(publisher3)
        publisher2.send(6) // this will be ignored (switchToLatest will allow publisher3 value only)
        publisher3.send(7)
        publisher3.send(8)
        publisher3.send(9)

        // Finally, you send a completion event to the current publisher, publisher3,
        // and another completion event to publishers.
        // This completes all active subscriptions.
        publisher3.send(completion: .finished)
        publishers.send(completion: .finished)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [1, 2, 4, 5, 7, 8, 9]) // Received switchToLatest values (3 and 6 is ignored!)
    }
}
