//
//  PrintingEventsTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 13/08/2023.
//

import Foundation
import Combine
import XCTest

/*
- Understanding the event flow in asynchronous programs has always been a challenge.
- It is particularly the case in the context of Combine, as chains of operators in a publisher may not all emit events at the same time.
- Combine provides a few operators to help with debugging your reactive flows. Knowing them will help you troubleshoot puzzling situations.

- `print(_:to:)` Prints log messages for all publishing events.
- https://developer.apple.com/documentation/combine/publisher/print(_:to:)
 */
final class PrintingEventsTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        cancellables = []
    }

    override func tearDown() {
        cancellables = nil

        super.tearDown()
    }

    func testPrintOperator() {
        let publisher = (1...3).publisher

        publisher
            .print("Logged a debug message") // This is magical operator for debug (using prefix in logging-message)
            .sink { _ in }
            .store(in: &cancellables)

        /*
         // Prints:
         //  Logged a debug message: receive subscription: (1...3)
         //  Logged a debug message: request unlimited
         //  Logged a debug message: receive value: (1)
         //  Logged a debug message: receive value: (2)
         //  Logged a debug message: receive value: (3)
         //  Logged a debug message: receive finished
         */
    }

    func testPrintOperatorWithTextOutputStream() {
        let publisher = (1...3).publisher
        let debugLogger = TimeStampDebugLogger()

        publisher
            .print("Logged a debug message", to: debugLogger) // Using prefix with custom TimeStamp debugger for print
            .sink { _ in }
            .store(in: &cancellables)

        /*
         // Prints:
         //  +0.00010s: Logged a debug message: receive subscription: (1...3)
         //  +0.00003s: Logged a debug message: request unlimited
         //  +0.00001s: Logged a debug message: receive value: (1)
         //  +0.00001s: Logged a debug message: receive value: (2)
         //  +0.00001s: Logged a debug message: receive value: (3)
         //  +0.00001s: Logged a debug message: receive finished
         */
    }
}

class TimeStampDebugLogger: TextOutputStream {
    private var previousDate = Date()
    private let formatter = NumberFormatter()

    init() {
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 5
    }

    func write(_ string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedString.isEmpty else { return }

        let nowDate = Date()
        let formattedDate = formatter.string(for: nowDate.timeIntervalSince(previousDate))!
        print("+\(formattedDate)s: \(trimmedString)")

        previousDate = nowDate
  }
}
