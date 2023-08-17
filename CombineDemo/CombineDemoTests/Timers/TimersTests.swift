//
//  TimersTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 17/08/2023.
//

import Foundation
import Combine
import XCTest

/*
- Timers
- Before the Dispatch framework was available, developers relied on RunLoop to asynchronously perform tasks and implement concurrency.
- Timer (NSTimer in Objective-C) could be used to create repeating and non-repeating timers.
- Then Dispatch arrived and with it, DispatchSourceTimer.
----------
- Using RunLoop
- The main thread and any thread you create, preferably using the Thread class, can have its own RunLoop.
- Always better, using the main RunLoop that runs the main thread of your application. `RunLoop.main`
- RunLoop class is not thread-safe. means You should only call RunLoop methods for the run loop of the current thread.
- RunLoop defines several methods which are relatively low-level, and the only one that lets you create `cancellable timers`
----------
- Using the Timer class
- Timer is the oldest timer that was available on the original Mac OS X, long before it was renamed “macOS.”
- It has always been tricky to use because of its delegation pattern and tight relationship with RunLoop.
- Combine brings a modern variant you can directly use as a publisher without all the setup boilerplate.
----------
- Using DispatchQueue
- You can use a dispatch queue to generate timer events.
- While the Dispatch framework has a DispatchTimerSource event source, Combine surprisingly doesn’t provide a timer interface to it. Instead, you’re going to use an alternative method to generate timer events in your queue.
 */
final class TimersTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var receivedValues: [String]?

    override func setUp() {
        super.setUp()

        cancellables = []
        receivedValues = []
    }

    override func tearDown() {
        cancellables = nil
        receivedValues = nil

        super.tearDown()
    }

    // RunLoop is not the best way to create a timer. You’ll be better off using the Timer class!
    func testRunLoopTimer() {
        let expectation = XCTestExpectation(description: "RunLoop timer")
        let runLoop = RunLoop.main

        // This timer does not pass any value and does not create a publisher.
        // It starts at the date specified in the after: parameter with the specified interval and tolerance, and that’s about it.
        runLoop.schedule(
            after: runLoop.now,
            interval: .seconds(1),
            tolerance: .milliseconds(100)) { [weak self] in
                self?.receivedValues?.append("Timer fired")
            }.store(in: &cancellables) // Its ONLY USEFULNESS in relation to Combine is that the Cancellable

        // Its ONLY USEFULNESS in relation to Combine is that the Cancellable it returns lets you stop the timer after a while.
        runLoop.schedule(after: .init(Date(timeIntervalSinceNow: 3.0))) { [weak self] in
            self?.cancellables.first?.cancel() // Cancelling Timer after 3 seconds

            XCTAssertEqual(self?.receivedValues, ["Timer fired", "Timer fired", "Timer fired", "Timer fired"])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testTimerClassTimer() {
        let expectation = XCTestExpectation(description: "Timer class based timer")

        // The two parameters on and in determine:
        // • Which RunLoop your timer attaches to. Here, the main thread‘s RunLoop.
        // • Which run loop mode(s) the timer runs in. Here, the default run loop mode.
        //
        // The publisher the timer returns is a ConnectablePublisher.
        // It’s a special variant of Publisher that won’t start firing upon subscription until you explicitly call its connect() method.
        // You can also use the autoconnect() operator which automatically connects when the first subscriber subscribes.
        let publisher = Timer.publish(every: 1.0, on: .main, in: .common)

        publisher
            .autoconnect()
            .sink { [weak self] value in
                print("Timer value is \(value)") // The timer repeatedly emits the current date (this value)
                self?.receivedValues?.append("Timer fired")
            }
            .store(in: &cancellables)

        // Cancelling Timer after 3 seconds
        RunLoop.main.schedule(after: .init(Date(timeIntervalSinceNow: 3.0))) { [weak self] in
            self?.cancellables.first?.cancel()

            XCTAssertEqual(self?.receivedValues, ["Timer fired", "Timer fired", "Timer fired"])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testDispatchQueueTimer() {
        let expectation = XCTestExpectation(description: "DispatchQueue based timer")

        // While the Dispatch framework has a DispatchTimerSource event source, Combine surprisingly doesn’t provide a timer interface to it.
        // Instead, you’re going to use an alternative method to generate timer events in your queue.

        // Create a Subject you will send timer values to.
        let publisher = PassthroughSubject<Void, Never>()

        let queue = DispatchQueue.main
        queue.schedule(after: queue.now, interval: .seconds(1)) {
            publisher.send(())
        }
        .store(in: &cancellables)

        publisher
            .sink { [weak self] value in
                self?.receivedValues?.append("Timer fired")
            }
            .store(in: &cancellables)

        // Cancelling Timer after 3 seconds
        RunLoop.main.schedule(after: .init(Date(timeIntervalSinceNow: 3.0))) { [weak self] in
            self?.cancellables.first?.cancel()

            XCTAssertEqual(self?.receivedValues, ["Timer fired", "Timer fired", "Timer fired"])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
