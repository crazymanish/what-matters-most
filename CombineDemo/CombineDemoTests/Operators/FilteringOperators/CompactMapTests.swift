//
//  CompactMapTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `compactMap(_:)`Calls a closure with each received element and publishes any returned optional that has a value.
/// - https://developer.apple.com/documentation/combine/publishers/collect/compactmap(_:)
///
/// - `tryCompactMap(_:)` Calls an error-throwing closure with each received element and publishes any returned optional that has a value.
/// - https://developer.apple.com/documentation/combine/publishers/collect/trycompactmap(_:)
final class CompactMapTests: XCTestCase {
    var publisher: Publishers.Sequence<[String], Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

        publisher = ["a", "1.24", "3", "def", "45", "0.23"].publisher
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil

        super.tearDown()
    }

    func testPublisherWithCompactMapOperator() {
        // Given: Publisher
        // publisher = ["a", "1.24", "3", "def", "45", "0.23"].publisher
        var receivedValues: [Double] = []

        // When: Sink(Subscription)
        publisher
            .compactMap { Double($0) } // Remove nil value after typecast
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
        XCTAssertEqual(receivedValues, [1.24, 3.0, 45.0, 0.23])
    }

    func testPublisherWithTryRemoveDuplicatesOperator() {
        // Given: Publisher
        // publisher = ["a", "1.24", "3", "def", "45", "0.23"].publisher
        var receivedValues: [Double] = []
        var receivedError: ApiError?

        // When: Sink(Subscription)
        publisher
            .tryCompactMap {
                if $0 == "def" { throw ApiError(code: .notFound) } // throwing error if there is def string

                return Double($0)
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
        XCTAssertEqual(receivedValues, [1.24, 3.0]) // after def, nothing is received because of error
        XCTAssertEqual(receivedError?.code, .notFound) // Finished with correct error
    }
}
