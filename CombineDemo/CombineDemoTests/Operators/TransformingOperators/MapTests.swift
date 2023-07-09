//
//  MapTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - Map Transforms all elements from the upstream publisher with a provided closure.
/// - https://developer.apple.com/documentation/combine/publishers/collect/map(_:)-8fi4q
final class MapTests: XCTestCase {
    var publisher: Publishers.Sequence<[Int], Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

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

        super.tearDown()
    }

    func testPublisherWithMapOperator() {
        // Given: Publisher
        // let publisher = [10, 20, 15, 25, 5].publisher
        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher
            .map { $0 * 2 } // map takes a closure that multiplies each value by 2
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            receivedValues += [value]
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [20, 40, 30, 50, 10])
    }

    func testPublisherWithMapOperatorScenario2() {
        // Given: Publisher
        // let publisher = [10, 20, 15, 25, 5].publisher
        var receivedValues: [String] = []
        let romanNumeralDict = [10:"X", 20:"XX", 15:"XV", 25:"XXV"]

        // map consumes each integer from the publisher and uses a dictionary to transform it from its numeral to a Roman equivalent, as a String.
        // If the map(_:)’s closure fails to look up a Roman numeral, it returns the string (unknown).

        // When: Sink(Subscription)
        publisher
            .map { romanNumeralDict[$0] ?? "(unknown)" }
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
        XCTAssertEqual(receivedValues, ["X", "XX", "XV", "XXV", "(unknown)"])
    }
}
