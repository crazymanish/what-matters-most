//
//  NotificationTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 03/04/2023.
//

import Foundation
import Combine
import XCTest

final class NotificationTests: XCTestCase {
    var notificationCenter: NotificationCenter!
    var notificationName: Notification.Name!
    var publisher: NotificationCenter.Publisher!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedNotification: Notification?
    var receivedNotificationCounter: Int!

    override func setUp() {
        super.setUp()

        notificationCenter = NotificationCenter.default
        notificationName = UIResponder.keyboardWillShowNotification
        publisher = NotificationCenter.Publisher(center: notificationCenter, name: notificationName)
        cancellables = []
        isFinishedCalled =  false
        receivedNotificationCounter = 0
    }

    override func tearDown() {
        notificationCenter = nil
        notificationName = nil
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil
        receivedNotification = nil
        receivedNotificationCounter = nil

        super.tearDown()
    }

    func testNotificationPublisher() {
        // Given: Sink(Subscription)
        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] notification in
            self?.receivedNotification = notification
            self?.receivedNotificationCounter += 1
        }
        .store(in: &cancellables)

        // When: Posting notification
        notificationCenter.post(.init(name: notificationName))

        // Then: Receiving correct notification
        XCTAssertFalse(isFinishedCalled)
        XCTAssertEqual(receivedNotificationCounter, 1)
        XCTAssertEqual(receivedNotification?.name.rawValue, "UIKeyboardWillShowNotification")
    }

    func testNotificationPublisherWithMultipleSink() {
        // Given: Multiple Sinks(Subscriptions)
        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] notification in
            self?.receivedNotification = notification
            self?.receivedNotificationCounter += 1
        }
        .store(in: &cancellables)

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            }
        } receiveValue: { [weak self] notification in
            self?.receivedNotification = notification
            self?.receivedNotificationCounter += 1
        }
        .store(in: &cancellables)

        // When: Posting notification
        notificationCenter.post(.init(name: notificationName))

        // Then: Receiving correct notification
        XCTAssertFalse(isFinishedCalled)
        XCTAssertEqual(receivedNotificationCounter, 2)
        XCTAssertEqual(receivedNotification?.name.rawValue, "UIKeyboardWillShowNotification")
    }
}
