//
//  FlatMapTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `flatMap(maxPublishers:_:)` Transforms all elements from an upstream publisher into a new publisher up to a maximum number of publishers you specify.
/// - https://developer.apple.com/documentation/combine/publishers/collect/flatmap(maxpublishers:_:)-36djm
final class FlatMapTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValues: [String]!

    override func setUp() {
        super.setUp()

        cancellables = []
        isFinishedCalled =  false
        receivedValues = []
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil
        receivedValues = []

        super.tearDown()
    }

    func testPublisherWithoutFlatMapOperator() {
        let firstMessenger = Messenger(name: "No:1", message: "Hi, i am no:1")

        // Given: Publisher
        let chatPublisher = CurrentValueSubject<Messenger, Never>(firstMessenger)

        // When: Sink(Subscription)
        chatPublisher
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] messenger in
            self?.receivedValues.append(messenger.message.value)
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled)
        XCTAssertEqual(receivedValues, ["Hi, i am no:1"])
    }

    func testPublisherWithoutFlatMapOperatorScenario2() {
        let firstMessenger = Messenger(name: "No:1", message: "Hi, i am no:1")
        let secondMessenger = Messenger(name: "No:2", message: "Hi, i am no:2")

        // Given: Publisher
        let chatPublisher = CurrentValueSubject<Messenger, Never>(firstMessenger)

        // When: Sink(Subscription)
        chatPublisher
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] messenger in
            self?.receivedValues.append(messenger.message.value)
        }
        .store(in: &cancellables)

        // When:
        firstMessenger.message.value = "No:1 has changed message"  // This is nested Publisher and is not received
        chatPublisher.value = secondMessenger

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled)
        XCTAssertEqual(receivedValues, ["Hi, i am no:1", "Hi, i am no:2"])
    }

    func testPublisherWithFlatMapOperator() {
        let firstMessenger = Messenger(name: "No:1", message: "Hi, i am no:1")
        let secondMessenger = Messenger(name: "No:2", message: "Hi, i am no:2")

        // Given: Publisher
        let chatPublisher = CurrentValueSubject<Messenger, Never>(firstMessenger)

        // When: Sink(Subscription)
        chatPublisher
            .flatMap{ $0.message }
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues.append(value)
        }
        .store(in: &cancellables)

        // When:
        firstMessenger.message.value = "No:1 has changed message" // This is nested Publisher and will receive because of flatMap
        chatPublisher.value = secondMessenger

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled)
        XCTAssertEqual(receivedValues, ["Hi, i am no:1", "No:1 has changed message", "Hi, i am no:2"])
    }

    func testPublisherWithFlatMapOperatorScenario2() {
        let firstMessenger = Messenger(name: "No:1", message: "Hi, i am no:1")
        let secondMessenger = Messenger(name: "No:2", message: "Hi, i am no:2")

        // Given: Publisher
        let chatPublisher = CurrentValueSubject<Messenger, Never>(firstMessenger)

        // When: Sink(Subscription)
        chatPublisher
            .flatMap{ $0.message }
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues.append(value)
        }
        .store(in: &cancellables)

        // When:
        firstMessenger.message.value = "No:1 has changed message" // This is nested Publisher and will receive because of flatMap
        chatPublisher.value = secondMessenger

        firstMessenger.message.value = "No:1 has changed message again"
        secondMessenger.message.value = "No:2 has changed message too"

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled)
        XCTAssertEqual(receivedValues, ["Hi, i am no:1", "No:1 has changed message", "Hi, i am no:2", "No:1 has changed message again", "No:2 has changed message too"])
    }

    func testPublisherWithFlatMapOperatorScenario3() {
        let firstMessenger = Messenger(name: "No:1", message: "Hi, i am no:1")
        let secondMessenger = Messenger(name: "No:2", message: "Hi, i am no:2")
        let thirdMessenger = Messenger(name: "No:3", message: "Hi, i am no:3")

        // Given: Publisher
        let chatPublisher = CurrentValueSubject<Messenger, Never>(firstMessenger)

        // When: Sink(Subscription)
        chatPublisher
            .flatMap(maxPublishers: .max(2)) { $0.message } // Adding here maximum two publishers (thirdMessenger will ignored)
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues.append(value)
        }
        .store(in: &cancellables)

        // When:
        firstMessenger.message.value = "No:1 has changed message" // This is nested Publisher and will receive because of flatMap
        chatPublisher.value = secondMessenger

        firstMessenger.message.value = "No:1 has changed message again"
        secondMessenger.message.value = "No:2 has changed message too"

        chatPublisher.value = thirdMessenger // Let's try 3rd messenger
        firstMessenger.message.value = "No:1 did not hear about No:3"
        secondMessenger.message.value = "No:2 also did not receive the No:3 message"


        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled)
        XCTAssertEqual(receivedValues, ["Hi, i am no:1", "No:1 has changed message", "Hi, i am no:2", "No:1 has changed message again", "No:2 has changed message too", "No:1 did not hear about No:3", "No:2 also did not receive the No:3 message"])
    }
}

struct Messenger {
    let name: String
    let message: CurrentValueSubject<String, Never>

    init(name: String, message: String) {
        self.name = name
        self.message = CurrentValueSubject(message)
    }
}
