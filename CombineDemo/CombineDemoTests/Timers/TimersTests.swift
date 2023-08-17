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
            self?.cancellables.first?.cancel()

            XCTAssertEqual(self?.receivedValues, ["Timer fired", "Timer fired", "Timer fired", "Timer fired"])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
