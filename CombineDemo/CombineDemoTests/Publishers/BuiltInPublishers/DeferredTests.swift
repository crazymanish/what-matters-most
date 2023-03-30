//
//  DeferredTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 30/03/2023.
//

import Foundation
import Combine
import XCTest

/// - `Deferred` is a built-in publisher that awaits subscription before running the supplied closure to create a publisher for the new subscriber.
/// - https://developer.apple.com/documentation/combine/deferred
final class DeferredTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValue: Int?
    var counter: Int!

    override func setUp() {
        super.setUp()

        cancellables = []
        isFinishedCalled =  false
        counter = 0
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil
        receivedValue = nil
        counter = nil

        super.tearDown()
    }

    func testDeferredPublisher() {
        let publisher = Deferred {
            Future<Int, Never> { [weak self] promise in
                guard let self else { fatalError() }

                self.counter = self.counter+1
                promise(.success(self.counter))
            }
        }

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValue, 1)
    }

    func testDeferredPublisherWithMultipleSink() {
        let publisher = Deferred {
            Future<Int, Never> { [weak self] promise in
                guard let self else { fatalError() }

                self.counter = self.counter+1
                promise(.success(self.counter))
            }
        }

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValue, 1)

        // Reset values
        isFinishedCalled = false
        receivedValue = nil

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

        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValue, 2) // Did you notice, Value is 2 means Deferred always create new publisher
    }
}
