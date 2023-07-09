//
//  LimitingValuesTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - Limiting values means receiving values until some condition is met, and then forcing the publisher to complete.
/// - For example, consider a request that may emit an unknown amount of values, but you only want a single emission and don’t care about the rest of them.
/// - Combine solves this set of problems with the prefix family of operators.
/// - This is opposite of dropping values operators: drop(), drop(while:), drop(:untilOutputFrom)
///
/// - `prefix(_:)` Republishes elements up to the specified maximum count.
/// - https://developer.apple.com/documentation/combine/publishers/collect/prefix(_:)
/// - `prefix(while:)` Republishes elements while a predicate closure indicates publishing should continue.
/// - https://developer.apple.com/documentation/combine/publishers/collect/prefix(while:)
/// - `tryPrefix(while:)` Republishes elements while an error-throwing predicate closure indicates publishing should continue.
/// - https://developer.apple.com/documentation/combine/publishers/collect/tryprefix(while:)
/// - `prefix(untilOutputFrom:)` Republishes elements until another publisher emits an element.
/// - https://developer.apple.com/documentation/combine/publishers/collect/prefix(untiloutputfrom:)
final class LimitingValuesTests: XCTestCase {
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

    func testPublisherWithPrefixWithSpecificCountOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .prefix(6)
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
        XCTAssertEqual(receivedValues, [1, 2, 3, 4, 5, 6]) // received (first) 6 elements
    }

    func testPublisherWithPrefixWhileOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .prefix(while: { $0 % 3 != 0 })
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
        XCTAssertEqual(receivedValues, [1, 2]) // received (while) [elements % 3 != 0]
    }

    func testPublisherWithTryPrefixWhileOperator() {
        // Given: Publisher
        let publisher = [1, 2, 3, 4, 5, 6, -1, 7, 8, 9, 10].publisher
        let range: CountableClosedRange<Int> = (1...100)
        var receivedValues: [Int] = []
        var receivedError: ApiError?

        // When: Sink(Subscription)
        publisher
            .tryPrefix {
                guard $0 != 0 else { throw ApiError(code: .notFound) }
                return range.contains($0)
            }
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
        XCTAssertTrue(isFinishedCalled) // Successful finished
        XCTAssertEqual(receivedValues, [1, 2, 3, 4, 5, 6])
        XCTAssertNil(receivedError)
    }

    func testPublisherWithTryPrefixWhileOperatorScenario2() {
        // Given: Publisher
        let publisher = [1, 2, 3, 4, 5, 6, 0, -1, 7, 8, 9, 10].publisher
        let range: CountableClosedRange<Int> = (1...100)
        var receivedValues: [Int] = []
        var receivedError: ApiError?

        // When: Sink(Subscription)
        publisher
            .tryDrop {
                guard $0 != 0 else { throw ApiError(code: .notFound) }
                return range.contains($0)
            }
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
        XCTAssertFalse(isFinishedCalled) // Successful finished not called, because it is finished with error
        XCTAssertEqual(receivedValues, []) // Nothing received because of error
        XCTAssertEqual(receivedError?.code, .notFound) // Finished with correct error
    }

    func testPublisherWithTryPrefixUntilOutputFromOperator() {
        // Given: Publisher
        let firstPublisher = PassthroughSubject<Int,Never>()
        let secondPublisher = PassthroughSubject<String,Never>()
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        firstPublisher
            .prefix(untilOutputFrom: secondPublisher)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true
                }
            } receiveValue: { value in
                receivedValues.append(value)
            }
            .store(in: &cancellables)

        // It will receive all values of firstPublisher, until secondPublisher kicks-in
        firstPublisher.send(1)
        firstPublisher.send(2)
        secondPublisher.send("This will kick-off the firstPublisher")
        firstPublisher.send(3)
        firstPublisher.send(4)
        firstPublisher.send(completion: .finished)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled) // Successful finished
        XCTAssertEqual(receivedValues, [1, 2]) // Received values only before the secondPublisher's output
    }
}
