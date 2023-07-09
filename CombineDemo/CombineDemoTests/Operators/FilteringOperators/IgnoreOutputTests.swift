//
//  IgnoreOutputTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 09/07/2023.
//

import Foundation
import Combine
import XCTest

/// - Sometimes, `all you want to know is that the publisher has finished emitting values`, disregarding the actual values.
/// - When such a scenario occurs, you can use the ignoreOutput operator
///
/// - `ignoreOutput()` Ignores all upstream elements, but passes along the upstream publisher’s completion state (finished or failed).
/// - https://developer.apple.com/documentation/combine/publishers/collect/ignoreoutput()
final class IgnoreOutputTests: XCTestCase {
    var publisher: Publishers.Sequence<[String], Never>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

        publisher = ["a", "1.24", "3", "def", "45", "0.23"].publisher
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil

        super.tearDown()
    }

    func testPublisherWithIgnoreOutputOperator() {
        // Given: Publisher
        // publisher = ["a", "1.24", "3", "def", "45", "0.23"].publisher
        var receivedValues: [Double] = []

        // When: Sink(Subscription)
        publisher
            .compactMap { Double($0) } // Remove nil value after typecast
            .ignoreOutput()
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
        XCTAssertTrue(isFinishedCalled) // Successful finished called
        XCTAssertEqual(receivedValues, []) // we are using `ignoreOutput` and receive nothing
    }

    func testPublisherWithIgnoreOutputWithErrorOperator() {
        // Given: Publisher
        // publisher = ["a", "1.24", "3", "def", "45", "0.23"].publisher
        var receivedError: ApiError?

        // When: Sink(Subscription)
        publisher
            .tryCompactMap {
                if $0 == "def" { throw ApiError(code: .notFound) } // throwing error if there is def string

                return Double($0)
            }
            .ignoreOutput()
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            case .failure(let error):
                receivedError = error as? ApiError
            }
        } receiveValue: { _ in} // This will never execute and we are using `ignoreOutput` and this line will never execute
        .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled) // Successful finished is not called because Upstream got an error
        XCTAssertEqual(receivedError?.code, .notFound) // Finished with correct error
    }
}
