//
//  CurrentValueSubjectTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 03/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `CurrentValueSubject` is a subject that wraps a single value and publishes a new element whenever the value changes.
/// - https://developer.apple.com/documentation/combine/currentvaluesubject
final class CurrentValueSubjectTests: XCTestCase {
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

    func testCurrentValueSubjectWithFinished() {
        let subject = CurrentValueSubject<Int, Never>(0)

        subject.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        XCTAssertEqual(subject.value, 0) // default current value

        // passing down new values with Subject
        subject.send(1) // Sending value before finish
        XCTAssertEqual(subject.value, 1) // current value

        subject.send(2) // Sending value before finish
        XCTAssertEqual(subject.value, 2) // current value

        subject.send(completion: .finished) // sending finish
        XCTAssertEqual(subject.value, 2) // current value

        subject.send(3) // Trying to send value after finish
        XCTAssertEqual(subject.value, 2) // current value

        XCTAssertTrue(isFinishedCalled) // Finished got called correctly
        XCTAssertEqual(receivedValues, [0, 1, 2]) // received values before finish
    }

    func testCurrentValueSubjectWithError() {
        let subject = CurrentValueSubject<Int, ApiError>(0)
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

        XCTAssertEqual(subject.value, 0) // default current value

        // passing down new values with Subject
        subject.send(1) // Sending value before finish
        XCTAssertEqual(subject.value, 1) // current value

        subject.send(2) // Sending value before finish
        XCTAssertEqual(subject.value, 2) // current value

        subject.send(completion: .failure(error)) // sending error
        XCTAssertEqual(subject.value, 2) // current value

        subject.send(3) // Trying to send value after error
        XCTAssertEqual(subject.value, 2) // current value

        XCTAssertFalse(isFinishedCalled) // Finished not get called
        XCTAssertEqual(receivedErrors, [error]) // Error got called correctly
        XCTAssertEqual(receivedValues, [0, 1, 2]) // received values before error
    }

    func testCurrentValueSubjectWithMultipleSink() {
        let subject = CurrentValueSubject<Int, Never>(0)

        subject.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        XCTAssertEqual(subject.value, 0) // default current value

        // passing down new values with Subject
        subject.send(1) // Sending value before finish
        XCTAssertEqual(subject.value, 1) // current value

        subject.send(2) // Sending value before finish
        XCTAssertEqual(subject.value, 2) // current value

        XCTAssertFalse(isFinishedCalled)
        XCTAssertEqual(receivedValues, [0, 1, 2])

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

        XCTAssertEqual(subject.value, 2) // last current value

        // passing down new values with Subject
        subject.send(10) // Sending value before finish
        XCTAssertEqual(subject.value, 10) // current value

        subject.send(20) // Sending value before finish
        XCTAssertEqual(subject.value, 20) // current value

        subject.send(completion: .finished) // sending finish
        XCTAssertEqual(subject.value, 20) // current value

        subject.send(30) // Trying to send value after finish
        XCTAssertEqual(subject.value, 20) // current value

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [2, 10, 10, 20, 20]) // received 2 times for both sink (before finish, did not receive 3)
    }

    func testCurrentValueSubjectWithMultipleSink2() {
        let subject = CurrentValueSubject<Int, Never>(0)

        subject.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)

        XCTAssertEqual(subject.value, 0) // default current value

        // passing down new values with Subject
        subject.send(1) // Sending value before finish
        XCTAssertEqual(subject.value, 1) // current value

        subject.send(2) // Sending value before finish
        XCTAssertEqual(subject.value, 2) // current value

        subject.send(completion: .finished) // sending finish (2nd below sink will not work, already received finish)
        XCTAssertEqual(subject.value, 2) // current value

        subject.send(3) // Trying to send value after finish
        XCTAssertEqual(subject.value, 2) // current value

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [0, 1, 2])

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

        XCTAssertEqual(subject.value, 2) // last current value

        // passing down new values with Subject
        subject.send(1) // Sending value after finish
        XCTAssertEqual(subject.value, 2) // last current value because already finished above

        subject.send(2) // Sending value after finish
        XCTAssertEqual(subject.value, 2) // last current value because already finished above

        subject.send(completion: .finished) // sending finish
        XCTAssertEqual(subject.value, 2) // last current value because already finished above

        subject.send(3) // Trying to send value after finish
        XCTAssertEqual(subject.value, 2) // last current value because already finished above

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, []) // Nothing received because already finished
    }
}
