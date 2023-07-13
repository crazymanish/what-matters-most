//
//  MergeWithTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 13/07/2023.
//

import Foundation
import Combine
import XCTest

/// - `merge(with:)` Combines elements from this publisher with those from another publisher of the same type, delivering an interleaved sequence of elements.
/// - https://developer.apple.com/documentation/combine/publishers/reduce/merge(with:)
/// - This operator interleaves emissions from `different publishers` of the `same type`.
final class MergeWithTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!

    override func setUp() {
        super.setUp()

        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil

        super.tearDown()
    }

    func testPublisherWithMergeWithOperator() {
        // Given: Publishers
        // Create three PassthroughSubjects that accept integers and no errors.
        let publisher1 = PassthroughSubject<Int, Never>()
        let publisher2 = PassthroughSubject<Int, Never>()
        let publisher3 = PassthroughSubject<Int, Never>()

        var receivedValues: [Int] = []

        // When: Sink(Subscription)
        publisher1
            .merge(with: publisher2, publisher3) // merging publisher2 and publisher3
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { value in
            receivedValues.append(value)
        }
        .store(in: &cancellables)

        // Sending publisher's value

        // Send value 1 and 2 to publisher1.
        publisher1.send(1)
        publisher1.send(2)

        publisher2.send(4)
        publisher1.send(3) // Sending using publisher1 after publisher2's 4
        publisher2.send(5)

        publisher3.send(7)
        publisher3.send(8)
        publisher2.send(6) // Sending using publisher2 after publisher3's 7, 8
        publisher3.send(9)

        // Finally, you send a completion event to the publishers,
        // This completes all active subscriptions.
        publisher1.send(completion: .finished)
        publisher2.send(completion: .finished)
        publisher3.send(completion: .finished)

        // Then: Receiving correct value
        XCTAssertTrue(isFinishedCalled)
        XCTAssertEqual(receivedValues, [1, 2, 4, 3, 5, 7, 8, 6, 9]) // Received merge values (see 3 and 6)
    }
}
