//
//  JustTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 27/03/2023.
//

import Foundation
import Combine
import XCTest

final class JustTests: XCTestCase {
    var justPublisher: Just<String>!
    var subject: JustTestingViewModel<String>!

    override func setUp() {
        super.setUp()

        justPublisher = Just("James bond")
        subject = JustTestingViewModel(justPublisher)
    }

    override func tearDown() {
        subject.cancellables.forEach { $0.cancel() }
        subject.cancellables.removeAll()
        justPublisher = nil
        subject = nil

        super.tearDown()
    }

    func testDefaultValue() {
        XCTAssertFalse(subject.isFinishedCalled)
        XCTAssertNil(subject.receivedValue)
    }

    func testValueAfterSink() {
        subject.performSink()

        XCTAssertTrue(subject.isFinishedCalled)
        XCTAssertEqual(subject.receivedValue, "James bond")
    }

    func testValueAfterReSink() {
        subject.performSink()

        XCTAssertTrue(subject.isFinishedCalled)
        XCTAssertEqual(subject.receivedValue, "James bond")

        // Reset values
        subject.isFinishedCalled = false
        subject.receivedValue = "0"

        // ReSink
        subject.performSink()

        XCTAssertTrue(subject.isFinishedCalled)
        XCTAssertEqual(subject.receivedValue, "James bond")
    }


    func testValueAfterReInitialized() {
        subject.performSink()

        XCTAssertTrue(subject.isFinishedCalled)
        XCTAssertEqual(subject.receivedValue, "James bond")

        // Reset values
        subject.isFinishedCalled = false
        subject.receivedValue = "0"

        // ReInitialized & Sink
        justPublisher = Just("James Bond 007")
        subject = JustTestingViewModel(justPublisher)
        subject.performSink()

        XCTAssertTrue(subject.isFinishedCalled)
        XCTAssertEqual(subject.receivedValue, "James Bond 007")
    }
}

final class JustTestingViewModel<OutputType> {
    let justPublisher: Just<OutputType>
    var cancellables: Set<AnyCancellable> = []

    init(_ justPublisher: Just<OutputType>) {
        self.justPublisher = justPublisher
    }

    var isFinishedCalled = false
    var receivedValue: OutputType?

    func performSink() {
        justPublisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)
    }
}
