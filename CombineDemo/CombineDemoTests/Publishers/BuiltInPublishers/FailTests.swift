//
//  FailTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 29/03/2023.
//

import Foundation
import Combine
import XCTest

/// - `Fail` is a built-in publisher that immediately terminates with the specified error.
/// - https://developer.apple.com/documentation/combine/fail
final class FailTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValue: Int?
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

    func testFailPublisher() {
        let publisher = Fail<Int, ApiError>(error: ApiError(code: .notFound))

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            case .failure(let error):
                self?.receivedError = error
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertFalse(isFinishedCalled) // finished is not called
        XCTAssertNil(receivedValue)
        XCTAssertEqual(receivedError?.code, .notFound) // finished with correct failure
    }

    func testFailPublisherWithMultipleSink() {
        let publisher = Fail<Int, ApiError>(error: ApiError(code: .notFound))

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            case .failure(let error):
                self?.receivedError = error
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertFalse(isFinishedCalled)
        XCTAssertNil(receivedValue)
        XCTAssertEqual(receivedError?.code, .notFound) // finished with correct failure

        // Reset values
        isFinishedCalled = false
        receivedValue = nil
        receivedError = nil

        // ReSink again
        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            case .failure(let error):
                self?.receivedError = error
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertFalse(isFinishedCalled)
        XCTAssertNil(receivedValue)
        XCTAssertEqual(receivedError?.code, .notFound) // finished with correct failure again
    }
}
