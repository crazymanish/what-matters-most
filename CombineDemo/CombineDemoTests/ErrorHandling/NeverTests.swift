//
//  NeverTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 16/08/2023.
//

import Foundation
import Combine
import XCTest
@testable import CombineDemo

/// - A publisher whose Failure is of type Never indicates that the publisher can never fail.
/// - A publisher with Never failure type lets you focus on consuming the publisher's values, while being absolutely sure the publisher will never fail. It can only complete successfully once it's done.
final class NeverTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValue: String?
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

    func testNeverErrorPublisher() {
        let publisher = Just("Never going to fail") // Just is always Never failure type

        publisher.sink { [weak self] completion in
            switch completion { // No need to implement failure switch
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValue, "Never going to fail")
        XCTAssertNil(receivedError)
    }

    func testNeverErrorWithFailureTypePublisher() {
        let publisher = Just("Never going to fail") // Just is always Never failure type

        publisher
            .setFailureType(to: ApiError.self) // This will change the above Never publisher, can return ApiError
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            case .failure(let error):           // Failure switch is required because of setFailureType
                self?.receivedError = error
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValue, "Never going to fail")
        XCTAssertNil(receivedError)
    }

    func testNeverErrorWithFailureTypeAndLaterMakeNeverAgainPublisher() {
        let publisher = Just("Never going to fail") // Just is always Never failure type

        publisher
            .setFailureType(to: ApiError.self) // This will change the above Never publisher, can return ApiError
            .assertNoFailure() // This will change it back to Never publisher, and will never return Error (it will crash if error received from Top stream)
            .sink { [weak self] completion in
            switch completion { // No need to implement failure switch
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValue, "Never going to fail")
        XCTAssertNil(receivedError)
    }
}
