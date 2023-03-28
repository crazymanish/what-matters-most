//
//  EmptyTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 28/03/2023.
//

import Foundation
import Combine
import XCTest

/// - `Empty` is a built-in publisher that never publishes any values, and optionally finishes immediately.
/// - https://developer.apple.com/documentation/combine/empty
final class EmptyTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        cancellables = []
    }

    override func tearDown() {
        cancellables = nil

        super.tearDown()
    }

    func testEmptyPublisherAsNever() {
        // This is a ”Never” publisher — one which never sends values and never finishes or fails — because of the initializer Empty(completeImmediately: false).
        let publisher = Empty<Int, Never>(completeImmediately: false)

        var isFinishedCalled = false
        var receivedValue: Int = -1

        publisher.sink { completion in
            switch completion {
            case .finished:
                isFinishedCalled = true
            }
        } receiveValue: { value in
            receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertFalse(isFinishedCalled) // finished is not called
        XCTAssertEqual(receivedValue, -1)
    }

    func testEmptyPublisherAsComplete() {
        // This publisher will never sends values and but will finishes.
        //
        // This is very useful:
        // When we want to say that a task is done and that task has been completed without passing a value.
        let publisher = Empty<Int, Never>(completeImmediately: true)

        var isFinishedCalled = false
        var receivedValue: Int = -1

        publisher.sink { completion in
            switch completion {
            case .finished:
                isFinishedCalled = true
            }
        } receiveValue: { value in
            receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled) // Tada: called
        XCTAssertEqual(receivedValue, -1)
    }
}
