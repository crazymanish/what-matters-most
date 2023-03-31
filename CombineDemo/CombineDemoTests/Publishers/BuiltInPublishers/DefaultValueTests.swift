//
//  DefaultValueTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 31/03/2023.
//

import Foundation
import Combine
import XCTest
@testable import CombineDemo

/// - `DefaultValue` is a custom publisher that emits an output to each subscriber just once, and then finishes.
/// - It works exactly same as Apple's built-in `Just` publisher
/// - https://developer.apple.com/documentation/combine/just/
final class DefaultValueTests: XCTestCase {
    var publisher: DefaultValue<String>!
    var subject: DefaultValueTestingViewModel<String>!

    override func setUp() {
        super.setUp()

        publisher = DefaultValue("James bond")
        subject = DefaultValueTestingViewModel(publisher)
    }

    override func tearDown() {
        publisher = nil
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
        publisher = DefaultValue("James Bond 007")
        subject = DefaultValueTestingViewModel(publisher)
        subject.performSink()

        XCTAssertTrue(subject.isFinishedCalled)
        XCTAssertEqual(subject.receivedValue, "James Bond 007")
    }
}

final class DefaultValueTestingViewModel<OutputType> {
    let publisher: DefaultValue<OutputType>
    var cancellables: Set<AnyCancellable> = []

    init(_ publisher: DefaultValue<OutputType>) {
        self.publisher = publisher
    }

    var isFinishedCalled = false
    var receivedValue: OutputType?

    func performSink() {
        publisher.sink { [weak self] completion in
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
