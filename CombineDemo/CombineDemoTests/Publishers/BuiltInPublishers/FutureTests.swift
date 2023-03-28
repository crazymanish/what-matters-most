//
//  FutureTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 28/03/2023.
//

import Foundation
import Combine
import XCTest

/// - `Future` is a built-in publisher that eventually produces a single value and then finishes or fails.
/// - https://developer.apple.com/documentation/combine/future
final class FutureTests: XCTestCase {
    var subject: FutureTestingViewModel!
    var futurePublisher: Future<Int, Never>!
    var dispatchQueue: DispatchQueueMock!

    override func setUp() {
        super.setUp()

        dispatchQueue = DispatchQueueMock()
        futurePublisher = Future{ promise in
            self.dispatchQueue.asyncAfter(deadline: .now()+1) {
                promise(.success(200))
            }
        }
        subject = FutureTestingViewModel(futurePublisher)
    }

    override func tearDown() {
        subject.cancellables.forEach { $0.cancel() }
        subject.cancellables.removeAll()
        subject = nil
        dispatchQueue = nil

        super.tearDown()
    }

    func testValueAfterSinkWithFuturePromise() {
        // Default values
        XCTAssertFalse(subject.isFinishedCalled)
        XCTAssertEqual(subject.receivedValues, [])

        // Sink
        dispatchQueue.execute?()
        subject.performSink()

        XCTAssertTrue(subject.isFinishedCalled)
        XCTAssertEqual(subject.receivedValues, [200])

        // ReSink
        subject.isFinishedCalled = false
        subject.performSink()

        XCTAssertTrue(subject.isFinishedCalled)
        XCTAssertEqual(subject.receivedValues, [200, 200])
    }
}

final class FutureTestingViewModel {
    let publisher: Future<Int, Never>
    var cancellables: Set<AnyCancellable> = []

    init(_ publisher: Future<Int, Never>) {
        self.publisher = publisher
    }

    var isFinishedCalled = false
    var receivedValues: [Int] = []

    func performSink() {
        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues += [value]
        }
        .store(in: &cancellables)
    }
}
