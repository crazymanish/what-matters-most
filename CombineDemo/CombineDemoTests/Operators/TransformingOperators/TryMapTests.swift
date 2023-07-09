//
//  TryMapTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `tryMap` Transforms all elements from the upstream publisher with a provided error-throwing closure.
/// - https://developer.apple.com/documentation/combine/publishers/collect/trymap(_:)
final class TryMapTests: XCTestCase {
    var publisher: Publishers.Sequence<[Int], Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedError: ApiError?

    override func setUp() {
        super.setUp()

        publisher = [10, 20, 15, 25, 5].publisher // Given: Publisher
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil
        receivedError = nil

        super.tearDown()
    }

    func testPublisherWithTryMapOperator() {
        // Given: Publisher
        // let publisher = [10, 20, 15, 25, 5].publisher
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
}
