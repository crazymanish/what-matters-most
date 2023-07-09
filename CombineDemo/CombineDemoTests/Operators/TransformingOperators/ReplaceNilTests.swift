//
//  ReplaceNilTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `replaceNil(with:)` Replaces nil elements in the stream with the provided element.
/// - https://developer.apple.com/documentation/combine/publishers/collect/replacenil(with:)
final class ReplaceNilTests: XCTestCase {
    var publisher: Publishers.Sequence<[Int?], Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

        publisher = [10, 20, nil, nil, 25].publisher // Given: Publisher
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil

        super.tearDown()
    }

    func testPublisherWithReplaceNilOperator() {
        // Given: Publisher
        // let publisher = [10, 20, nil, nil, 25].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .replaceNil(with: 0) // Replace nil to 0
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
        XCTAssertEqual(receivedValues, [10, 20, 0, 0, 25])
    }

    func testPublisherWithReplaceNilWithMapOperator() {
        // Given: Publisher
        // let publisher = [10, 20, nil, nil, 25].publisher
        var receivedValues: [String] = []
        let romanNumeralDict = [10:"X", 20:"XX", 25:"XXV", 0:"0"]

        // When: Sink(Subscription)
        publisher
            .replaceNil(with: 0) // Replace nil to 0
            .map { romanNumeralDict[$0]! }
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
        XCTAssertEqual(receivedValues, ["X", "XX", "0", "0", "XXV"])
    }
}
