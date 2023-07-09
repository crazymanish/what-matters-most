//
//  RemoveDuplicateTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `removeDuplicates(by:)`Publishes only elements that don’t match the previous element, as evaluated by a provided closure.
/// - https://developer.apple.com/documentation/combine/publishers/collect/removeduplicates(by:)
///
/// - `tryRemoveDuplicates(by:)` Publishes only elements that don’t match the previous element, as evaluated by a provided error-throwing closure.
/// - https://developer.apple.com/documentation/combine/publishers/collect/tryremoveduplicates(by:)
final class RemoveDuplicateTests: XCTestCase {
    var publisher: Publishers.Sequence<[Int], Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

        publisher = [0, 0, 0, 0, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4].publisher
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil

        super.tearDown()
    }

    func testPublisherWithRemoveDuplicatesOperator() {
        // Given: Publisher
        // publisher = [0, 0, 0, 0, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .removeDuplicates() // Remove all duplicates
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
        XCTAssertEqual(receivedValues, [0, 1, 2, 3, 4])
    }

    func testPublisherWithRemoveDuplicatesOperatorScenario2() {
        // Given: Publisher
        // publisher = [0, 0, 0, 0, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .removeDuplicates { $0 == 3 && $1 == 3 } // Remove duplicate only for 3
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
        XCTAssertEqual(receivedValues, [0, 0, 0, 0, 1, 2, 2, 3, 4, 4, 4, 4])
    }

    func testPublisherWithTryRemoveDuplicatesOperator() {
        // Given: Publisher
        // publisher = [0, 0, 0, 0, 1, 2, 2, 3, 3, 3, 4, 4, 4, 4].publisher
        var receivedValues: [Int] = []
        var receivedError: ApiError?

        // When: Sink(Subscription)
        publisher
            .tryRemoveDuplicates {
                if $0 == 3 && $1 == 3 { throw ApiError(code: .notFound) } // throwing error if there are duplicate of 3

                return $0 == $1
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
        XCTAssertFalse(isFinishedCalled) // Successful finished is not called because Upstream got an error
        XCTAssertEqual(receivedValues, [0, 1, 2, 3]) // after 3, nothing is received because of error
        XCTAssertEqual(receivedError?.code, .notFound) // Finished with correct error
    }
}
