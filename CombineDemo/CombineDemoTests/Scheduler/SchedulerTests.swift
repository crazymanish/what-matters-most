//
//  SchedulerTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 17/08/2023.
//

import Foundation
import Combine
import XCTest

/*
- Scheduler
- https://developer.apple.com/documentation/combine/scheduler/
- A scheduler is a protocol that defines when and how to execute a closure.
- You can use a scheduler to execute code as soon as possible, or after a future date.
- Schedulers can accept options to control how they execute the actions passed to them. These options may control factors like which threads or dispatch queues execute the actions.
----------------
- The Combine framework provides two fundamental operators to work with schedulers:
- `subscribe(on:)` and `subscribe(on:options:)` `create` the subscription (start the work) on the specified scheduler.
- `subscribe(on:)`: A publisher that receives elements from an upstream publisher on a specific scheduler.
- https://developer.apple.com/documentation/combine/publishers/subscribeon/
- `receive(on:)` and `receive(on:options:)` `deliver` values on the specified scheduler.
- `receive(on:)`: A publisher that delivers elements to its downstream subscriber on a specific scheduler.
- https://developer.apple.com/documentation/combine/publishers/receiveon
----------------
- In addition, the following `Time Manipulation Operators` take a scheduler and scheduler options as parameters.
 • debounce(for:scheduler:options:)
 • delay(for:tolerance:scheduler:options:)
 • measureInterval(using:options:)
 • throttle(for:scheduler:latest:)
 • timeout(_:scheduler:options:customError:)
----------------
 */
final class SchedulerTests: XCTestCase {
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

    func testPublisherWithExpensiveComputationInMainThread() {
        let expectation = XCTestExpectation(description: "Performing expensive computation in main thread")

        // Given: Publisher
        // ExpensiveComputation: which simulates a long-running computation that emits a string after the specified duration.
        let publisher = Publishers.ExpensiveComputation(duration: 3)

        // You obtain the current execution thread number. The main thread (thread number 1) is the default thread your code runs in.
        let currentThread = Thread.current.number
        print("Start computation publisher on thread \(currentThread)")
        XCTAssertEqual(currentThread, 1)

        // When: Sink(Subscription)
        publisher
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

    func testPublisherWithExpensiveComputationInBackgroundThread() {
        let expectation = XCTestExpectation(description: "Performing expensive computation in background thread")

        // Given: Publisher
        // ExpensiveComputation: which simulates a long-running computation that emits a string after the specified duration.
        let publisher = Publishers.ExpensiveComputation(duration: 3)

        // A serial queue you’ll use to trigger the computation on a specific scheduler. DispatchQueue adopts the Scheduler protocol.
        let queue = DispatchQueue(label: "testing serial queue")

        // You obtain the current execution thread number. The main thread (thread number 1) is the default thread your code runs in.
        let currentThread = Thread.current.number
        print("Start computation publisher on thread \(currentThread)")
        XCTAssertEqual(currentThread, 1)

        // When: Sink(Subscription)
        publisher
            .subscribe(on: queue) // `subscribe(on:)`: `create` the subscription (start the work) on the specified scheduler i.e background queue.
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true

                    expectation.fulfill()
                }
            } receiveValue: { [weak self] value in
                let thread = Thread.current.number
                print("Received computation result on thread \(thread): '\(value)'")
                XCTAssertNotEqual(thread, 1) // 1 mean Main-Thread, it should not be 1 because we are using background queue

                DispatchQueue.main.async { // We need this switch to update UI, because code were switched to background thread using in `subscribe(on: queue)` step (see below for better alternative)
                    self?.receivedValues?.append(value)
                }
            }
            .store(in: &cancellables)


        wait(for: [expectation], timeout: 5.0)
    }

    func testPublisherWithExpensiveComputationInBackgroundThreadAndThenReceiveInMainThread() {
        let expectation = XCTestExpectation(description: "Performing expensive computation in background thread and later switch to main thread")

        // Given: Publisher
        // ExpensiveComputation: which simulates a long-running computation that emits a string after the specified duration.
        let publisher = Publishers.ExpensiveComputation(duration: 3)

        // A serial queue you’ll use to trigger the computation on a specific scheduler. DispatchQueue adopts the Scheduler protocol.
        let queue = DispatchQueue(label: "testing serial queue")

        // You obtain the current execution thread number. The main thread (thread number 1) is the default thread your code runs in.
        let currentThread = Thread.current.number
        print("Start computation publisher on thread \(currentThread)")
        XCTAssertEqual(currentThread, 1)

        // When: Sink(Subscription)
        publisher
            .subscribe(on: queue) // `subscribe(on:)`: `create` the subscription (start the work) on the specified scheduler i.e background queue.
            .receive(on: DispatchQueue.main) // `receive(on:)` `deliver` values on the specified scheduler i.e main thread.
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinishedCalled = true

                    expectation.fulfill()
                }
            } receiveValue: { [weak self] value in
                let thread = Thread.current.number
                print("Received computation result on thread \(thread): '\(value)'")
                XCTAssertEqual(thread, 1) // 1 mean Main-Thread

                self?.receivedValues?.append(value) // No need `DispatchQueue.main.async` thanks to `.receive(on: DispatchQueue.main)` step
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }
}

// https://github.com/kodecocodes/comb-materials/blob/editions/4.0/17-schedulers/projects/Final.playground/Sources/Computation.swift
final class ComputationSubscription<Output>: Subscription {
    private let duration: TimeInterval
    private let sendCompletion: () -> Void
    private let sendValue: (Output) -> Subscribers.Demand
    private let finalValue: Output
    private var cancelled = false

    init(duration: TimeInterval, sendCompletion: @escaping () -> Void, sendValue: @escaping (Output) -> Subscribers.Demand, finalValue: Output) {
        self.duration = duration
        self.finalValue = finalValue
        self.sendCompletion = sendCompletion
        self.sendValue = sendValue
    }

    func request(_ demand: Subscribers.Demand) {
        if !cancelled {
            print("Beginning expensive computation on thread \(Thread.current.number)")
        }

        Thread.sleep(until: Date(timeIntervalSinceNow: duration))

        if cancelled {
            print("Expensive computation completed but was cancelled")
        } else {
            print("Completed expensive computation on thread \(Thread.current.number)")
            _ = self.sendValue(self.finalValue)
            self.sendCompletion()
        }
    }

    func cancel() {
        print("Cancelling expensive computation")
        cancelled = true
    }
}

extension Publishers {
    struct ExpensiveComputation: Publisher {
        typealias Output = String
        typealias Failure = Never

        let duration: TimeInterval

        init(duration: TimeInterval) {
            self.duration = duration
        }

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            Swift.print("ExpensiveComputation subscriber received on thread \(Thread.current.number)")

            let subscription = ComputationSubscription(
                duration: duration,
                sendCompletion: { subscriber.receive(completion: .finished) },
                sendValue: { subscriber.receive($0) },
                finalValue: "Computation complete")

            subscriber.receive(subscription: subscription)
        }
    }
}

// https://github.com/kodecocodes/comb-materials/blob/editions/4.0/17-schedulers/projects/Final.playground/Sources/Thread.swift
enum Regex {
  static let threadNumber = try! NSRegularExpression(pattern: "number = (\\d+)", options: .caseInsensitive)
}

extension Thread {
    var number: Int {
        let desc = self.description
        if let numberMatches = Regex.threadNumber.firstMatch(in: desc, range: NSMakeRange(0, desc.count)) {
            let s = NSString(string: desc).substring(with: numberMatches.range(at: 1))
            return Int(s) ?? 0
        }
        return 0
    }
}
