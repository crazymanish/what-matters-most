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
*/
final class KeyValueObservingTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValue: String?

    override func setUp() {
        super.setUp()

        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        cancellables = nil
        isFinishedCalled = nil
        receivedValue = nil

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
            self?.receivedValue = value
        }
        .store(in: &cancellables)

        // KVO change
        userInfo.name = "James Bond"

        XCTAssertFalse(isFinishedCalled) // Not yet finished, will keep receiving new KVO change
        XCTAssertEqual(receivedValue, "James Bond") // Received latest KVO change
    }
}

class UserInfo: NSObject {
    @objc dynamic var name: String = "Manish"
}
