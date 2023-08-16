//
//  DealingWithFailureTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 16/08/2023.
//

import Foundation
import Combine
import XCTest
@testable import CombineDemo

/// - All try* operators
/// - The try-prefixed operators let you throw errors from within them, while non-try operators do not.
/// - All try-prefixed operators in Combine behave the same way when it comes to errors.
/// - Example: tryMap, tryFirst, tryLast etc
///
/// - `mapError(_:)` Converts any failure from the upstream publisher into a new error.
/// - https://developer.apple.com/documentation/combine/fail/maperror(_:)/
///
/// - `replaceError(with:)` Replaces any errors in the stream with the provided element.
/// - If the upstream publisher fails with an error, this publisher emits the provided element, then finishes normally.
/// - This replaceError(with:) functionality is useful when you want to handle an error by sending a single replacement element and end the stream.
/// - https://developer.apple.com/documentation/combine/deferred/replaceerror(with:)/
final class DealingWithFailureTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValue: String?
    var receivedError: ApiError?

    override func setUp() {
        super.setUp()

        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil
        receivedValue = nil
        receivedError = nil

        super.tearDown()
    }

    func testPublisherWithTryMapOperator() {
        // Given: Publisher
        let publisher = [10, 20, 15, 25, 5].publisher
        var receivedValues: [String] = []

        // When: Sink(Subscription)
        publisher
            .tryMap { try self.romanNumeral(from: $0) }
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            case .failure(let error):
                self?.receivedError = error as? ApiError
            }
        } receiveValue: { value in
            receivedValues.append(value)
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled) // Successful finished is not called because Upstream got an error
        XCTAssertEqual(receivedValues, ["X", "XX", "XV", "XXV"])
        XCTAssertEqual(receivedError?.code, .notFound) // Finished with correct error
    }

    private func romanNumeral(from: Int) throws -> String {
        let romanNumeralDict = [10:"X", 20:"XX", 15:"XV", 25:"XXV"]

        guard let numeral = romanNumeralDict[from] else {
            throw ApiError(code: .notFound)
        }

        return numeral
    }

    func testMapErrorOperator() {
        // Given: Publisher
        let publisher = [10, 20, 15, 25, 5].publisher
        var receivedValues: [String] = []
        var receivedGenericError: GenericError?

        // When: Sink(Subscription)
        publisher
            .tryMap { try self.romanNumeral(from: $0) } // This is returning ApiError
            .mapError { GenericError(wrappedError: $0) } // This will change ApiError to GenericError
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            case .failure(let error):
                receivedGenericError = error
            }
        } receiveValue: { value in
            receivedValues.append(value)
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled) // Successful finished is not called because Upstream got an error
        XCTAssertEqual(receivedValues, ["X", "XX", "XV", "XXV"])
        XCTAssertNotNil(receivedGenericError) // Finished with correct error
    }

    func testPublisherWithReplaceErrorOperator() {
        // Given: Publisher
        let publisher = [10, 20, 15, 25, 5].publisher
        var receivedValues: [String] = []

        // When: Sink(Subscription)
        publisher
            .tryMap { try self.romanNumeral(from: $0) }
            .replaceError(with: "ReplacedError") // This will make it NEVER fail type
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
        XCTAssertTrue(isFinishedCalled) // Successful finished is called because Upstream error is replaced by a valid string value
        XCTAssertEqual(receivedValues, ["X", "XX", "XV", "XXV", "ReplacedError"])
        XCTAssertNil(receivedError) // Finished with no error
    }
}

struct GenericError: Error { var wrappedError: Error }
