//
//  SchedulerImplementationTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 17/08/2023.
//

import Foundation
import Combine
import XCTest

/*
- Scheduler implementations
- Apple provides several concrete implementations of the Scheduler protocol:
-----------
- `ImmediateScheduler:` A simple scheduler that executes code immediately on the current thread, which is the default execution context unless modified using subscribe(on:), receive(on:) or any of the other operators which take a scheduler as parameter.
- You can only use this scheduler for immediate actions. If you attempt to schedule actions after a specific date, this scheduler ignores the date and performs them immediately.
- https://developer.apple.com/documentation/combine/immediatescheduler
-----------
- `RunLoop:` Tied to Foundation’s Thread object.
- `DispatchQueue:` Can either be serial or concurrent.
- `OperationQueue:` A queue that regulates the execution of work items.
 */
final class SchedulerImplementationTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValues: [String]?
    var receivedError: ApiError?

    override func setUp() {
        super.setUp()

        cancellables = []
        receivedValues = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil
        receivedValues = nil
        receivedError = nil

        super.tearDown()
    }

    func testPublisherWithImmediateScheduler() {
        let expectation = XCTestExpectation(description: "Performing expensive computation in main thread with immediateScheduler")

        // Given: Publisher
        // ExpensiveComputation: which simulates a long-running computation that emits a string after the specified duration.
        let publisher = Publishers.ExpensiveComputation(duration: 3)

        // You obtain the current execution thread number. The main thread (thread number 1) is the default thread your code runs in.
        let currentThread = Thread.current.number
        print("Start computation publisher on thread \(currentThread)")
        XCTAssertEqual(currentThread, 1)

        let immediateScheduler = ImmediateScheduler.shared

        // When: Sink(Subscription)
        publisher
            .receive(on: immediateScheduler) // immediateScheduler executes immediately on the current thread, and in this case that thread is the main thread.
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true

                    expectation.fulfill()
                }
            } receiveValue: { [weak self] value in
                let thread = Thread.current.number
                print("Received computation result on thread \(thread): '\(value)'")
                XCTAssertEqual(currentThread, 1)

                self?.receivedValues?.append(value)
            }
            .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled) // Successful finished
        XCTAssertEqual(receivedValues, ["Computation complete"])
        XCTAssertNil(receivedError) // No error

        wait(for: [expectation], timeout: 5.0)
    }
}
