//
//  KeyValueObservingTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 18/08/2023.
//

import Foundation
import Combine
import XCTest
@testable import CombineDemo

/*
- Combine provides a few options around this:
 - It provides a publisher for any property of an object that is KVO (Key-Value Observing)-compliant.
 - The ObservableObject protocol handles cases where multiple variables could change.
----------
- `publisher(for:options:)` for key-value observing
- https://developer.apple.com/documentation/combine/performing-key-value-observing-with-combine
- This is mostly for ObjectiveC because Swift language doesn’t directly support KVO, marking your properties `@objc dynamic` forces the compiler to generate hidden methods that trigger the KVO machinery.
----------
- `ObservableObject` A type of object with a publisher that emits before the object has changed.
- https://developer.apple.com/documentation/combine/observableobject
- By default an ObservableObject synthesizes an objectWillChange publisher that emits the changed value before any of its @Published properties changes.
*/
final class KeyValueObservingTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValues: [String]?

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

        super.tearDown()
    }

    func testObjectiveCTypeKVOPublisher() {
        let userInfo = UserInfo()
        let publisher = userInfo.publisher(for: \.name)

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValues?.append(value)
        }
        .store(in: &cancellables)

        // KVO change
        userInfo.name = "James Bond"

        XCTAssertFalse(isFinishedCalled) // Not yet finished, will keep receiving new KVO change
        XCTAssertEqual(receivedValues, ["Manish", "James Bond"]) // Received latest KVO change
    }

    func testSwiftTypeKVOPublisher() {
        let userDetail = UserDetail()
        let publisher = userDetail.objectWillChange // emits the changed value before any of its @Published properties changes.

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] _ in
            self?.receivedValues?.append(userDetail.name)
        }
        .store(in: &cancellables)

        // KVO change
        userDetail.name = "James Bond"
        userDetail.name = "James Bond 2"

        XCTAssertFalse(isFinishedCalled) // Not yet finished, will keep receiving new KVO change
        XCTAssertEqual(receivedValues, ["Manish", "James Bond"]) // Received latest KVO change
    }
}

class UserInfo: NSObject {
    @objc dynamic var name: String = "Manish"
}

class UserDetail: ObservableObject {
    @Published var name: String = "Manish"
}
