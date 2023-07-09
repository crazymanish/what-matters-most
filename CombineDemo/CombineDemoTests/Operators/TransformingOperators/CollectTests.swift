//
//  CollectTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `collect()` The collect operator provides a convenient way to transform a stream of individual values from a publisher into an array of those values.
/// - Collects all received elements, and emits a single array of the collection when the upstream publisher finishes.
/// - https://developer.apple.com/documentation/combine/publishers/collect/collect()
final class CollectTests: XCTestCase {
    var publisher: Publishers.Sequence<[Int], Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValues: [Int]!
    var receivedCollectedValues: [[Int]]!

    override func setUp() {
        super.setUp()

        publisher = [10, 20, 15, 25, 5].publisher // Given: Publisher
        cancellables = []
        isFinishedCalled =  false
        receivedValues = []
        receivedCollectedValues = []
    }

    override func tearDown() {
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil
        receivedValues = nil
        receivedCollectedValues = nil

        super.tearDown()
    }

    func testPublisherWithoutCollectOperator() {
        // Given: Publisher
        // let publisher = [10, 20, 15, 25, 5].publisher

        // When: Sink(Subscription)
        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [10, 20, 15, 25, 5])
    }

    func testPublisherWithCollectOperator() {
        // Given: Publisher
        // let publisher = [10, 20, 15, 25, 5].publisher

        // When: Sink(Subscription)
        publisher
            .collect() // Collect operator will collect all elements
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedCollectedValues += [value]
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedCollectedValues, [[10, 20, 15, 25, 5]])
    }

    func testPublisherWithContidionalCollectOperator() {
        // Given: Publisher
        // let publisher = [10, 20, 15, 25, 5].publisher

        // When: Sink(Subscription)
        publisher
            .collect(2) // Collect operator will collect only 2 values at a time
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedCollectedValues += [value]
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedCollectedValues, [[10, 20], [15, 25], [5]])
    }
}
