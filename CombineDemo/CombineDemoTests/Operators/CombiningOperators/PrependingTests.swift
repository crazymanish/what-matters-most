//
//  PrependingTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 13/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `prepend(_:)` Prefixes a publisher’s output with the specified values.
/// - We’ll use them to add values that emit before any values from our original publisher.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/prepend(_:)
final class PrependingTests: XCTestCase {
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

    func testPublisherWithPrependOperator() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .prepend(1, 2)
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
        XCTAssertEqual(receivedValues, [1, 2, 5, 6, 7, 8, 9, 10]) // Received prepended values (1, 2)
    }

    func testPublisherWithPrependOperatorAsArray() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .prepend([1, 2]) // As array
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
        XCTAssertEqual(receivedValues, [1, 2, 5, 6, 7, 8, 9, 10]) // Received prepended values (1, 2)
    }

    func testPublisherWithPrependOperatorAsSet() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .prepend(Set(1...2)) // As Set
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
        XCTAssertEqual(receivedValues, [1, 2, 5, 6, 7, 8, 9, 10]) // Received prepended values (1, 2)
    }

    func testPublisherWithPrependOperatorAsStride() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .prepend(stride(from: -1, to: 5, by: 2)) // As stride
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
        XCTAssertEqual(receivedValues, [-1, 1, 3, 5, 6, 7, 8, 9, 10]) // Received prepended values stride by 2
    }

    func testPublisherWithPrependOperatorAsCombination() {
        // Given: Publisher
        // publisher = (5...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .prepend([20, 30]) // As array
            .prepend(stride(from: -1, to: 5, by: 2)) // As stride
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
        XCTAssertEqual(receivedValues, [-1, 1, 3, 20, 30, 5, 6, 7, 8, 9, 10]) // Received prepended values correctly
    }
}
