//
//  IntSubscriberTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 12/04/2023.
//

import Foundation
import Combine
import XCTest

final class IntSubscriberTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValues: [Int]!

    override func setUp() {
        super.setUp()

        cancellables = []
        isFinishedCalled =  false
        receivedValues = []
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil
        receivedValues = nil

        super.tearDown()
    }

    func testIntSubscriber() {
        let publisher = [1, 2, 3, 4, 5].publisher

        // Custom IntSubscriber
        let subscriber = IntSubscriber()
        publisher.subscribe(subscriber)

        XCTAssertFalse(subscriber.isFinishedCalled) // finished is not called
        XCTAssertEqual(subscriber.receivedValues, [1, 2, 3]) // received only .max(3) values defined inside IntSubscriber

        // built-in (sink) Subscriber
        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled) // finished is called
        XCTAssertEqual(receivedValues, [1, 2, 3, 4, 5]) // received all publisher values
    }

    func testIntSubscriberWithFinished() {
        let publisher = [1, 2, 3].publisher

        // Custom IntSubscriber
        let subscriber = IntSubscriber()
        publisher.subscribe(subscriber)

        XCTAssertTrue(subscriber.isFinishedCalled) // finished is now called, after .max(3) values
        XCTAssertEqual(subscriber.receivedValues, [1, 2, 3]) // received all/.max(3) values defined inside IntSubscriber

        // built-in (sink) Subscriber
        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled) // finished is called
        XCTAssertEqual(receivedValues, [1, 2, 3]) // received all publisher values
    }
}

private class IntSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never

    var isFinishedCalled: Bool = false
    var receivedValues: [Int] = []

    func receive(subscription: Subscription) {
        subscription.request(.max(3))
    }

    func receive(_ input: Int) -> Subscribers.Demand {
        receivedValues += [input]

        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        isFinishedCalled = true
    }
}
