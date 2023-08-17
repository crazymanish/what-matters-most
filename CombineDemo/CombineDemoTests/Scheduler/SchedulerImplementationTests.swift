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
- The RunLoop scheduler is used to execute tasks on a particular run loop.
- Actions on a run loop can be unsafe because RunLoops are not thread-safe. Therefore, using a DispatchQueue is a better option.
-----------
- `DispatchQueue:` Can either be serial or concurrent.
- Dispatch queues are FIFO queues. Dispatch queues execute tasks either serially or concurrently.
- Work submitted to dispatch queues executes on a pool of threads managed by the system. Except for the dispatch queue representing your app’s main thread, the system makes no guarantees about which thread it uses to execute a task.
- A DispatchQueue can be either serial (the default) or concurrent.
-----------
- `OperationQueue:` A queue that regulates the execution of operations.
- It is a rich regulation mechanism that lets you create advanced operations with dependencies.
- OperationQueue uses DispatchQueue under the hood. Moreover, there is one parameter in each OperationQueue that explains everything: It’s `maxConcurrentOperationCount`. It defaults to a system-defined number that allows an operation queue to execute a large number of operations concurrently.
- By default, an OperationQueue behaves like a concurrent DispatchQueue. Setting maxConcurrentOperationCount to 1 is equivalent to using a serial queue
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
                XCTAssertEqual(thread, 1)

                self?.receivedValues?.append(value)
            }
            .store(in: &cancellables)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled) // Successful finished
        XCTAssertEqual(receivedValues, ["Computation complete"])
        XCTAssertNil(receivedError) // No error

        wait(for: [expectation], timeout: 5.0)
    }

    func testPublisherWithExpensiveComputationInMainQueue() {
        let expectation = XCTestExpectation(description: "Performing expensive computation in main queue")

        // Given: Publisher
        // ExpensiveComputation: which simulates a long-running computation that emits a string after the specified duration.
        let publisher = Publishers.ExpensiveComputation(duration: 3)

        // Main Queue
        let queue = DispatchQueue.main

        // You obtain the current execution thread number. The main thread (thread number 1) is the default thread your code runs in.
        let currentThread = Thread.current.number
        print("Start computation publisher on thread \(currentThread)")
        XCTAssertEqual(currentThread, 1)

        // When: Sink(Subscription)
        publisher
            .subscribe(on: queue) // `subscribe(on:)`: `create` the subscription (start the work) on the specified scheduler i.e background queue.
            .receive(on: queue)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true

                    expectation.fulfill()
                }
            } receiveValue: { [weak self] value in
                let thread = Thread.current.number
                print("Received computation result on thread \(thread): '\(value)'")
                XCTAssertEqual(thread, 1)

                DispatchQueue.main.async { // We need to update UI, because code were switched to background thread using in `subscribe(on: queue)` step (see below for better alternative)
                    self?.receivedValues?.append(value)
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testPublisherWithExpensiveComputationInSerialQueue() {
        let expectation = XCTestExpectation(description: "Performing expensive computation in serial queue")

        // Given: Publisher
        // ExpensiveComputation: which simulates a long-running computation that emits a string after the specified duration.
        let publisher = Publishers.ExpensiveComputation(duration: 3)

        // A serial queue
        let queue = DispatchQueue(label: "serial queue")

        // You obtain the current execution thread number. The main thread (thread number 1) is the default thread your code runs in.
        let currentThread = Thread.current.number
        print("Start computation publisher on thread \(currentThread)")
        XCTAssertEqual(currentThread, 1)

        // When: Sink(Subscription)
        publisher
            .subscribe(on: queue) // `subscribe(on:)`: `create` the subscription (start the work) on the specified scheduler i.e background queue.
            .receive(on: queue) // We will receive result in non-main thread, because using serial queue
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true

                    expectation.fulfill()
                }
            } receiveValue: { [weak self] value in
                let thread = Thread.current.number
                print("Received computation result on thread \(thread): '\(value)'")
                XCTAssertNotEqual(thread, 1) // 1 mean Main-Thread, it should not be 1

                DispatchQueue.main.async { // We need to update UI, because code were switched to background thread using in `subscribe(on: queue)` step (see below for better alternative)
                    self?.receivedValues?.append(value)
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testPublisherWithExpensiveComputationInParallelQueue() {
        let expectation = XCTestExpectation(description: "Performing expensive computation in parallel queue")

        // Given: Publisher
        // ExpensiveComputation: which simulates a long-running computation that emits a string after the specified duration.
        let publisher = Publishers.ExpensiveComputation(duration: 3)

        // A parallel queue
        let queue = DispatchQueue(label: "parallel queue", attributes: .concurrent)

        // You obtain the current execution thread number. The main thread (thread number 1) is the default thread your code runs in.
        let currentThread = Thread.current.number
        print("Start computation publisher on thread \(currentThread)")
        XCTAssertEqual(currentThread, 1)

        // When: Sink(Subscription)
        publisher
            .subscribe(on: queue) // `subscribe(on:)`: `create` the subscription (start the work) on the specified scheduler i.e background queue.
            .receive(on: queue) // We will receive result in non-main thread, because using serial queue
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true

                    expectation.fulfill()
                }
            } receiveValue: { [weak self] value in
                let thread = Thread.current.number
                print("Received computation result on thread \(thread): '\(value)'")
                XCTAssertNotEqual(thread, 1) // 1 mean Main-Thread, it should not be 1

                DispatchQueue.main.async { // We need to update UI, because code were switched to background thread using in `subscribe(on: queue)` step (see below for better alternative)
                    self?.receivedValues?.append(value)
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testPublisherWitOperationQueue() {
        let expectation = XCTestExpectation(description: "using OperationQueue (concurrent DispatchQueue)")

        // Given: Publisher
        let publisher = (1...10).publisher
        let queue = OperationQueue()

        // When: Sink(Subscription)
        publisher
            .receive(on: queue) // We will receive result in non-main thread, because using OperationQueue (concurrent DispatchQueue)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true

                    expectation.fulfill()
                }
            } receiveValue: { value in
                let thread = Thread.current.number
                print("Received result on thread \(thread): '\(value)'")
                XCTAssertNotEqual(thread, 1) // 1 mean Main-Thread, it should not be 1
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testPublisherWitOperationQueueWithMaxConcurrentOperationCount() {
        let expectation = XCTestExpectation(description: "using OperationQueue with 1 maxConcurrentOperationCount (serial DispatchQueue)")

        // Given: Publisher
        let publisher = (1...10).publisher
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        // When: Sink(Subscription)
        publisher
            .receive(on: queue) // We will receive result in non-main thread, because using OperationQueue (concurrent DispatchQueue)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true

                    expectation.fulfill()
                }
            } receiveValue: { value in
                let thread = Thread.current.number
                print("Received result on thread \(thread): '\(value)'")
                XCTAssertNotEqual(thread, 1) // 1 mean Main-Thread, it should not be 1
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }
}
