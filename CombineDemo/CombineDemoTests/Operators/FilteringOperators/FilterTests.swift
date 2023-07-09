//
//  FilterTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `filter(_:)` Republishes all elements that match a provided closure.
/// - https://developer.apple.com/documentation/combine/publishers/collect/filter(_:)
///
/// - `tryFilter(_:)` Republishes all elements that match a provided error-throwing closure.
/// - https://developer.apple.com/documentation/combine/publishers/collect/tryfilter(_:)
final class FilterTests: XCTestCase {
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

    func testPublisherWithFilterOperator() {
        // Given: Publisher
        // publisher = (1...10).publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .filter { $0 % 3 == 0 } // Filter multiple of 3
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
        XCTAssertEqual(receivedValues, [3, 6, 9]) // Received filter values (multiple of 3)
    }

    func testPublisherWithTryFilterOperator() {
        // Given: Publisher
        // let publisher = (1...10).publisher
        var receivedValues: [Int] = []
        var receivedError: ApiError?

        // When: Sink(Subscription)
        publisher
            .tryFilter { try self.isFoundInCache(value: $0) }
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
        XCTAssertEqual(receivedValues, [1, 2, 3]) // 4 is not found in cache
        XCTAssertEqual(receivedError?.code, .notFound) // Finished with correct error
    }

    private func isFoundInCache(value: Int) throws -> Bool {
        let cache = [1, 2, 3, 5, 6]

        guard cache.contains(value) else {
            throw ApiError(code: .notFound)
        }

        return true
    }
}
