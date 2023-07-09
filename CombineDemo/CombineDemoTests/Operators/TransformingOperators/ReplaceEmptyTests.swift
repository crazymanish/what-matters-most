//
//  ReplaceEmptyTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `replaceEmpty(with:)` Replaces an empty stream with the provided element.
/// - Use replaceEmpty(with:) to provide a replacement element if the upstream publisher finishes without producing any elements.
/// - Conversely, providing a non-empty publisher publishes all elements and the publisher then terminates normally.
/// - https://developer.apple.com/documentation/combine/publishers/collect/replaceempty(with:)
final class ReplaceEmptyTests: XCTestCase {
    var publisher: Publishers.Sequence<[Int], Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

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
        publisher = [].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .replaceEmpty(with: 0) // Replace empty publisher to 0 for downstream
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
        XCTAssertEqual(receivedValues, [0])
    }

    func testPublisherWithReplaceNilWithMapOperator() {
        // Given: Publisher
        publisher = [10, 20].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .replaceEmpty(with: 0) // Will do nothing, because publisher is a non-empty and will publishes all elements and the publisher then terminates normally.
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
        XCTAssertEqual(receivedValues, [10, 20])
    }
}
