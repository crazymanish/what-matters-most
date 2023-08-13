//
//  DebuggerBreakpointTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 13/08/2023.
//

import Foundation
import Combine
import XCTest

/*
- in some situations, we really need to introspect things at certain times in the debugger to figure out what’s wrong.
- There are two debugger operators:

 - `breakpointOnError()` Raises a debugger signal upon receiving a failure.
 - https://developer.apple.com/documentation/combine/publisher/breakpointonerror()
 - When the upstream publisher fails with an error, this publisher raises the SIGTRAP signal, which stops the process in the debugger.
 - Otherwise, this publisher passes through values and completions as-is.

 - `breakpoint(receiveSubscription:receiveOutput:receiveCompletion:)` Raises a debugger signal when a provided closure needs to stop the process in the debugger.
   - receiveSubscription: A closure that executes when the publisher receives a subscription. Return true from this closure to raise SIGTRAP, or false to continue.
   - receiveOutput: A closure that executes when the publisher receives a value. Return true from this closure to raise SIGTRAP, or false to continue.
   - receiveCompletion: A closure that executes when the publisher receives a completion. Return true from this closure to raise SIGTRAP, or false to continue.
 - https://developer.apple.com/documentation/combine/publisher/breakpoint(receivesubscription:receiveoutput:receivecompletion:)
 - Use breakpoint(receiveSubscription:receiveOutput:receiveCompletion:) to examine one or more stages of the subscribe/publish/completion process and stop in the debugger, based on conditions you specify.
 - When any of the provided closures returns true, this operator raises the SIGTRAP signal to stop the process in the debugger.
 - Otherwise, this publisher passes through values and completions as-is.
 */
final class DebuggerBreakpointTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        cancellables = []
    }

    override func tearDown() {
        cancellables = nil

        super.tearDown()
    }

    func testBreakpointOnErrorOperator() {
        let publisher = PassthroughSubject<String?, ApiError>()

        publisher
            .tryMap({ _ in
                throw ApiError(code: .notFound)
            })
            .breakpointOnError() // The breakpointOnError() operator receives this completion and stops the app in the debugger.
            .sink { completion in
                print("Completion: \(String(describing: completion))")
            } receiveValue: { stringValue in
                print("Result: \(String(describing: stringValue))")
            }
            .store(in: &cancellables)

        publisher.send("sending test value for break-point debugger")

        /*
         - it will throw "error: Execution was interrupted, reason: signal SIGTRAP."
         - Also include stack trace information in Xcode's left-side debugger panel.
         */
    }

    func testBreakpointOnReceivedValueOperator() {
        let publisher = PassthroughSubject<String, ApiError>()

        publisher
            .breakpoint(receiveOutput: { stringValue in
                return stringValue == "DEBUGGER" // When the breakpoint receives the string “DEBUGGER”, it returns true, which stops the app in the debugger.
            })
            .sink { completion in
                print("Completion: \(String(describing: completion))")
            } receiveValue: { stringValue in
                print("Result: \(String(describing: stringValue))")
            }
            .store(in: &cancellables)

        publisher.send("this will not hit Debugger breakpoint")
        publisher.send("DEBUGGER") // This will stop the app in the debugger after hitting the breakpoint

        /*
         - it will throw "error: Execution was interrupted, reason: signal SIGTRAP."
         - Also include stack trace information in Xcode's left-side debugger panel.
         */
    }
}
