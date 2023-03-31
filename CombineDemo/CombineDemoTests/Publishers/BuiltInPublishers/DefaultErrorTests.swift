//
//  DefaultErrorTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 31/03/2023.
//

import Foundation
import Combine
import XCTest
@testable import CombineDemo

/// - `DefaultError` is a custom publisher that immediately terminates with the specified error.
/// - It works exactly same as Apple's built-in `Fail` publisher
/// - https://developer.apple.com/documentation/combine/fail
final class DefaultErrorTests: XCTestCase {
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

    func testErrorPublisher() {
        let publisher = DefaultError<Int, ApiError>(error: ApiError(code: .notFound))

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

    func testErrorPublisherWithMultipleSink() {
        let publisher = DefaultError<Int, ApiError>(error: ApiError(code: .notFound))

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
