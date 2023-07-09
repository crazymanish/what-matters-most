//
//  ScanTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `scan(_:_:)` Transforms elements from the upstream publisher by providing the current element to a closure along with the last value returned by the closure.
/// - https://developer.apple.com/documentation/combine/publishers/collect/scan(_:_:)
final class ScanTests: XCTestCase {
    var publisher: Publishers.Sequence<[Int], Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

        publisher = [1, 2, 3, 4, 5].publisher
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil

        super.tearDown()
    }

    func testPublisherWithScanOperator() {
        // Given: Publisher
        // publisher = [1, 2, 3, 4, 5].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .scan(0) { $0 + $1 } // Initial value is 0, and later will keep doing the prefix-sum
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
        XCTAssertEqual(receivedValues, [1, 3, 6, 10, 15]) // [0+1, 1+2, 3+3, 6+4, 10+5]
    }

    func testPublisherWithScanOperatorScenario2() {
        // Given: Publisher
        // publisher = [1, 2, 3, 4, 5].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .scan(100) { $0 + $1 } // Initial value is 100, and later will keep doing the prefix-sum
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
        XCTAssertEqual(receivedValues, [101, 103, 106, 110, 115]) // [100+1, 101+2, 103+3, 106+4, 110+5]
    }
}
