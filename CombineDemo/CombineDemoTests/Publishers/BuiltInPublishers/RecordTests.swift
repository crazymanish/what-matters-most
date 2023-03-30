//
//  RecordTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 30/03/2023.
//

import Foundation
import Combine
import XCTest

/// - `Record` is a built-in publisher that allows for recording a series of inputs and a completion, for later playback to each subscriber.
/// - https://developer.apple.com/documentation/combine/record
final class RecordTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedErrors: [ApiError]!
    var receivedValues: [Int]!
    var counter: Int!

    override func setUp() {
        super.setUp()

        cancellables = []
        isFinishedCalled =  false
        receivedErrors = []
        receivedValues = []
        counter = 0
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil
        receivedErrors = nil
        receivedValues = nil
        counter = nil

        super.tearDown()
    }

    func testRecordPublisherWithFinished() {
        let publisher = Record<Int, Never>(output: [1, 2, 3], completion: .finished)

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [1, 2, 3])
    }

    func testRecordPublisherWithError() {
        let error = ApiError(code: .notFound)
        let publisher = Record<Int, ApiError>(output: [1, 2, 3], completion: .failure(error))

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            case .failure(let error):
                self?.receivedErrors += [error]
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        XCTAssertFalse(isFinishedCalled) // Finished not get called
        XCTAssertEqual(receivedErrors, [error])
        XCTAssertEqual(receivedValues, [1, 2, 3])
    }

    func testRecordPublisherWithMultipleSink() {
        let publisher = Record<Int, Never>(output: [1, 2, 3], completion: .finished)

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [1, 2, 3])

        // Reset values
        isFinishedCalled = false
        receivedValues = []

        // ReSink again
        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [1, 2, 3])
    }
}
