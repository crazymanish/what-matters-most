//
//  FindingValuesTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `first()` Publishes the first element of a stream, then finishes.
/// - https://developer.apple.com/documentation/combine/publishers/collect/first()
/// - `first(where:)` Publishes the first element of a stream to satisfy a predicate closure, then finishes normally.
/// - https://developer.apple.com/documentation/combine/publishers/collect/first(where:)
/// - `tryFirst(where:)` Publishes the first element of a stream to satisfy a throwing predicate closure, then finishes normally.
/// - https://developer.apple.com/documentation/combine/publishers/collect/tryfirst(where:)
///
/// - `last()` Publishes the last element of a stream, after the stream finishes.
/// - https://developer.apple.com/documentation/combine/publishers/collect/last()
/// - `last(where:)` Publishes the last element of a stream that satisfies a predicate closure, after upstream finishes.
/// - https://developer.apple.com/documentation/combine/publishers/collect/last(where:)
/// - `tryLast(where:)` Publishes the last element of a stream that satisfies an error-throwing predicate closure, after the stream finishes.
/// - https://developer.apple.com/documentation/combine/publishers/collect/trylast(where:)
final class FindingValuesTests: XCTestCase {
    var publisher: Publishers.Sequence<ClosedRange<Int>, Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

        publisher = (1...10).publisher
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil

        super.tearDown()
    }

    func testPublisherWithFirstOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .first()
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
        XCTAssertEqual(receivedValues, [1]) // Received (first) b/w 1 to 10
    }

    func testPublisherWithFirstWhereOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .first(where: { $0 % 3 == 0 })  // filter (first) multiple of 3
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
        XCTAssertEqual(receivedValues, [3]) // Received (first) multiple of 3 b/w 1 to 10
    }

    func testPublisherWithTryFirstWhereOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []
        var receivedError: ApiError?

        // When: Sink(Subscription)
        publisher
            .tryFirst(where: {
                if $0 == 3 { throw ApiError(code: .notFound) }

                return $0 % 4 == 0
            })  // filter (first) multiple of 3
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true
                case .failure(let error):
                    receivedError = error as? ApiError
                }
            } receiveValue: { value in
                receivedValues.append(value)
            }
            .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled) // Successful finished is not called because Upstream got an error
        XCTAssertEqual(receivedValues, []) // nothing is received because of error
        XCTAssertEqual(receivedError?.code, .notFound) // Finished with correct error
    }

    func testPublisherWithLastOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .last()
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
        XCTAssertEqual(receivedValues, [10]) // Received (last) b/w 1 to 10
    }

    func testPublisherWithLastWhereOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .last(where: { $0 % 3 == 0 })  // filter (last) multiple of 3
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
        XCTAssertEqual(receivedValues, [9]) // Received (last) multiple of 3 b/w 1 to 10
    }

    func testPublisherWithTryLastWhereOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []
        var receivedError: ApiError?

        // When: Sink(Subscription)
        publisher
            .tryLast(where: {
                if $0 == 3 { throw ApiError(code: .notFound) }

                return $0 % 4 == 0
            })  // filter (first) multiple of 3
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true
                case .failure(let error):
                    receivedError = error as? ApiError
                }
            } receiveValue: { value in
                receivedValues.append(value)
            }
            .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled) // Successful finished is not called because Upstream got an error
        XCTAssertEqual(receivedValues, []) // nothing is received because of error
        XCTAssertEqual(receivedError?.code, .notFound) // Finished with correct error
    }
}
