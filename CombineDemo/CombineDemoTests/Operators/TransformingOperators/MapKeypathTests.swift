//
//  MapKeypathTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - Map Transforms all elements from the upstream publisher with a provided closure.
/// - https://developer.apple.com/documentation/combine/publishers/mapkeypath
/// - https://developer.apple.com/documentation/combine/publishers/collect/map(_:_:)
final class MapKeypathTests: XCTestCase {
    var publisher: Publishers.Sequence<[CGPoint], Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

        publisher = [CGPoint(x: 10, y: 5), CGPoint(x: 20, y: 50)].publisher // Given: Publisher
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil

        super.tearDown()
    }

    func testPublisherWithMapKeypathOperator() {
        // Given: Publisher
        // let publisher = [CGPoint(x: 10, y: 5), CGPoint(x: 20, y: 50)].publisher
        var receivedXValues: [Double] = []
        var receivedYValues: [Double] = []

        // When: Sink(Subscription)
        publisher
            .map(\.x, \.y) // using map(_:_:) to map into two key paths
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { xValue, yValue in
            receivedXValues += [xValue]
            receivedYValues += [yValue]
        }
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedXValues, [10.0, 20.0])
        XCTAssertEqual(receivedYValues, [5.0, 50.0])
    }
}
