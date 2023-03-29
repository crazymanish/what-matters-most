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
    var isFinishedCalled: Bool!
    var receivedValue: Int?

    override func setUp() {
        super.setUp()

        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil
        receivedValue = nil

        super.tearDown()
    }

    func testEmptyPublisherAsNever() {
        // This is a ”Never” publisher — one which never sends values and never finishes or fails — because of the initializer Empty(completeImmediately: false).
        let publisher = Empty<Int, Never>(completeImmediately: false)

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertFalse(isFinishedCalled) // finished is not called
        XCTAssertNil(receivedValue)
    }

    func testEmptyPublisherAsComplete() {
        // This publisher will never sends values and but will finishes.
        //
        // This is very useful:
        // When we want to say that a task is done and that task has been completed without passing a value.
        let publisher = Empty<Int, Never>(completeImmediately: true)

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled) // Tada: called
        XCTAssertNil(receivedValue)
    }

    func testEmptyPublisherAsCompleteWithMultipleSink() {
        // This publisher will never sends values and but will finishes.
        //
        // This is very useful:
        // When we want to say that a task is done and that task has been completed without passing a value.
        let publisher = Empty<Int, Never>(completeImmediately: true)

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled) // Tada: called
        XCTAssertNil(receivedValue)

        // Reset values
        isFinishedCalled = false

        // ReSink again
        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled) // Tada: called again
        XCTAssertNil(receivedValue)
    }
}
