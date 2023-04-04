//
//  UserDefaultTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 04/04/2023.
//

import Foundation
import Combine
import XCTest

extension UserDefaults {
    var counterKey: String { "counter" }

    @objc dynamic var counter: Int {
        get {
            integer(forKey: counterKey)
        } set{
            set(newValue, forKey: counterKey)
        }
    }
}

final class UserDefaultTests: XCTestCase {
    var userDefaults: UserDefaults!
    var publisher: KeyValueObservingPublisher<UserDefaults, Int>!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedValue: Int!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults.standard
        publisher = userDefaults.publisher(for: \.counter)
        cancellables = []
        isFinishedCalled =  false
        receivedValue = 0
    }

    override func tearDown() {
        userDefaults = nil
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil
        receivedValue = nil

        super.tearDown()
    }

    func testUserDefaultPublisher() {
        // Given: Sink(Subscription)
        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] value in
            self?.receivedValue = value
            print(value)
        }
        .store(in: &cancellables)

        // When: Saving counter in userDefaults
        userDefaults.counter = 007

        // Then: Receiving correct value
        XCTAssertFalse(isFinishedCalled)
        XCTAssertEqual(receivedValue, 7)
    }
}
