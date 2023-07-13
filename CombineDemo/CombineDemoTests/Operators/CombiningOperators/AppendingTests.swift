//
//  AppendingTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 13/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `append(_:)` Appends a publisher’s output with the specified elements.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/append(_:)
final class AppendingTests: XCTestCase {
    var publisher: Publishers.Sequence<ClosedRange<Int>, Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

        publisher = (5...10).publisher
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil

        super.tearDown()
    }

    func testPublisherWithAppendOperator() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .append(1, 2)
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
        XCTAssertEqual(receivedValues, [5, 6, 7, 8, 9, 10, 1, 2]) // Received appended values (1, 2)
    }

    func testPublisherWithAppendOperatorAsArray() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .append([1, 2]) // As array
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
        XCTAssertEqual(receivedValues, [5, 6, 7, 8, 9, 10, 1, 2]) // Received appended values (1, 2)
    }

    func testPublisherWithAppendOperatorAsSet() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .append(Set(1...2)) // As Set
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
        XCTAssertEqual(receivedValues, [5, 6, 7, 8, 9, 10, 1, 2]) // Received appended values (1, 2)
    }

    func testPublisherWithAppendOperatorAsStride() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .append(stride(from: -5, to: 5, by: 2)) // As stride
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
        XCTAssertEqual(receivedValues, [5, 6, 7, 8, 9, 10, -5, -3, -1, 1, 3]) // Received appended values stride by 2
    }

    func testPublisherWithAppendOperatorAsCombination() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .append([20, 30]) // As array
            .append(stride(from: -1, to: 5, by: 2)) // As stride
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
        XCTAssertEqual(receivedValues, [5, 6, 7, 8, 9, 10, 20, 30, -1, 1, 3]) // Received appended values correctly
    }

    func testPublisherWithAppendOperatorAsPublisher() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // Appending publisher2 at the beginning of publisher1. Values from publisher1 emit only after publisher2 completes.
        let publisher2 = (11...12).publisher

        // When: Sink(Subscription)
        publisher
            .append([20, 30]) // As array
            .append(publisher2) // As Publisher
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
        XCTAssertEqual(receivedValues, [5, 6, 7, 8, 9, 10, 20, 30, 11, 12]) // Received appended values correctly
    }

    func testPublisherWithAppendOperatorAsSubjectWithoutComplete() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // Appending publisher2 at the beginning of publisher1. Values from publisher1 emit only after publisher2 completes.
        let publisher2 = PassthroughSubject<Int, Never>()

        // When: Sink(Subscription)
        publisher
            .append([20, 30]) // As array
            .append(publisher2) // As Publisher
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            receivedValues.append(value)
        }
        .store(in: &cancellables)

        // Sending publisher2's subject value
        publisher2.send(11)
        publisher2.send(12)

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled) // publisher2 is not yet finished/completed.
        XCTAssertEqual(receivedValues, [5, 6, 7, 8, 9, 10, 20, 30, 11, 12]) // Received appended values
    }

    func testPublisherWithAppendOperatorAsSubjectWithComplete() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // Appending publisher2 at the beginning of publisher1. Values from publisher1 emit only after publisher2 completes.
        let publisher2 = PassthroughSubject<Int, Never>()

        // When: Sink(Subscription)
        publisher
            .append([20, 30]) // As array
            .append(publisher2) // As Publisher
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            receivedValues.append(value)
        }
        .store(in: &cancellables)

        // Sending publisher2's subject value
        publisher2.send(11)
        publisher2.send(12)
        publisher2.send(completion: .finished) // Sending completion

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [5, 6, 7, 8, 9, 10, 20, 30, 11, 12]) // Received appended values
    }
}
