//
//  DroppingValuesTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// -  We can use it when we want to ignore values from one publisher until a second one starts publishing,
/// - or if we want to ignore a specific amount of values at the start of the stream.
///
/// - `dropFirst(_:)` Omits the specified number of elements before republishing subsequent elements.
/// - https://developer.apple.com/documentation/combine/publishers/collect/dropfirst(_:)
/// - `drop(while:)` Omits elements from the upstream publisher until a given closure returns false, before republishing all remaining elements.
/// - https://developer.apple.com/documentation/combine/publishers/collect/drop(while:)
/// - `tryDrop(while:)` Omits elements from the upstream publisher until an error-throwing closure returns false, before republishing all remaining elements.
/// - https://developer.apple.com/documentation/combine/publishers/collect/trydrop(while:)
/// - `drop(untilOutputFrom:)` Ignores elements from the upstream publisher until it receives an element from a second publisher.
/// - https://developer.apple.com/documentation/combine/publishers/collect/drop(untiloutputfrom:)
final class DroppingValuesTests: XCTestCase {
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

    func testPublisherWithDropFirstOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .dropFirst()
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
        XCTAssertEqual(receivedValues, [2, 3, 4, 5, 6, 7, 8, 9, 10]) // drop (first)
    }

    func testPublisherWithDropFirstWithSpecificCountOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .dropFirst(6)
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
        XCTAssertEqual(receivedValues, [7, 8, 9, 10]) // drop (first) 6 elements
    }

    func testPublisherWithDropWhileOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .drop(while: { $0 % 3 != 0 })
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
        XCTAssertEqual(receivedValues, [3, 4, 5, 6, 7, 8, 9, 10]) // drop (while) [elements % 3 != 0]
    }

    func testPublisherWithTryDropWhileOperator() {
        // Given: Publisher
        let publisher = [1, 2, 3, 4, 5, 6, -1, 7, 8, 9, 10].publisher
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
        XCTAssertTrue(isFinishedCalled) // Successful finished
        XCTAssertEqual(receivedValues, [-1, 7, 8, 9, 10])
        XCTAssertNil(receivedError)
    }

    func testPublisherWithTryDropWhileOperatorScenario2() {
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

    func testPublisherWithTryDropUntilOutputFromOperator() {
        // Given: Publisher
        let firstPublisher = PassthroughSubject<Int,Never>()
        let secondPublisher = PassthroughSubject<String,Never>()
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        firstPublisher
            .drop(untilOutputFrom: secondPublisher)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true
                }
            } receiveValue: { value in
                receivedValues.append(value)
            }
            .store(in: &cancellables)

        // It will drop all values of firstPublisher, until secondPublisher kicks-in
        firstPublisher.send(1)
        firstPublisher.send(2)
        secondPublisher.send("This will kick-off the firstPublisher")
        firstPublisher.send(3)
        firstPublisher.send(4)
        firstPublisher.send(completion: .finished)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled) // Successful finished
        XCTAssertEqual(receivedValues, [3, 4]) // Received values only after the secondPublisher's output
    }
}
