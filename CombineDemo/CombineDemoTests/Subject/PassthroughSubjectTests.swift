//
//  PassthroughSubject.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 25/06/2023.
//

import Foundation
import Combine
import XCTest

/// - `PassthroughSubject` is a subject that broadcasts elements to downstream subscribers.
/// - https://developer.apple.com/documentation/combine/passthroughsubject
final class PassthroughSubjectTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedErrors: [ApiError]!
    var receivedValues: [Int]!

    override func setUp() {
        super.setUp()

        cancellables = []
        isFinishedCalled =  false
        receivedErrors = []
        receivedValues = []
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil
        receivedErrors = nil
        receivedValues = nil

        super.tearDown()
    }

    func testPassthroughSubjectWithFinished() {
        let subject = PassthroughSubject<Int, Never>()

        subject.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        // passing down new values with Subject
        subject.send(1) // Sending value before finish
        subject.send(2) // Sending value before finish
        subject.send(completion: .finished) // sending finish
        subject.send(3) // Trying to send value after finish

        XCTAssertTrue(isFinishedCalled) // Finished got called correctly
        XCTAssertEqual(receivedValues, [1, 2]) // received values before finish
    }

    func testPassthroughSubjectWithError() {
        let subject = PassthroughSubject<Int, ApiError>()
        let error = ApiError(code: .notFound)

        subject.sink { [weak self] completion in
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

        // passing down new values with Subject
        subject.send(1) // Sending value before finish
        subject.send(2) // Sending value before finish
        subject.send(completion: .failure(error)) // sending error
        subject.send(3) // Trying to send value after error

        XCTAssertFalse(isFinishedCalled) // Finished not get called
        XCTAssertEqual(receivedErrors, [error]) // Error got called correctly
        XCTAssertEqual(receivedValues, [1, 2]) // received values before error
    }

    func testPassthroughSubjectWithMultipleSink() {
        let subject = PassthroughSubject<Int, Never>()

        subject.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        // passing down new values with Subject
        subject.send(1) // Sending value before finish
        subject.send(2) // Sending value before finish

        XCTAssertFalse(isFinishedCalled)
        XCTAssertEqual(receivedValues, [1, 2])

        // Reset values
        isFinishedCalled = false
        receivedValues = []

        // ReSink again
        subject.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        // passing down new values with Subject
        subject.send(1) // Sending value before finish
        subject.send(2) // Sending value before finish
        subject.send(completion: .finished) // sending finish
        subject.send(3) // Trying to send value after finish

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [1, 1, 2, 2]) // received 2 times for both sink (before finish, did not receive 3)
    }

    func testPassthroughSubjectWithMultipleSink2() {
        let subject = PassthroughSubject<Int, Never>()

        subject.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        // passing down new values with Subject
        subject.send(1) // Sending value before finish
        subject.send(2) // Sending value before finish
        subject.send(completion: .finished) // sending finish (2nd below sink will not work, already received finish)
        subject.send(3) // Trying to send value after finish

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [1, 2])

        // Reset values
        isFinishedCalled = false
        receivedValues = []

        // ReSink again
        subject.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        // passing down new values with Subject
        subject.send(1) // Sending value before finish
        subject.send(2) // Sending value before finish
        subject.send(completion: .finished) // sending finish
        subject.send(3) // Trying to send value after finish

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, []) // Nothing received because already finished
    }
}
