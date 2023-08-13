//
//  HandlingEventsTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 13/08/2023.
//

import Foundation
import Combine
import XCTest

/*
- Besides printing out information, it is often useful to perform actions upon specific events.
- We call this performing side effects, as actions you take “on the side” don’t directly impact further publishers down the stream, but can have an effect like modifying an external variable.

- `handleEvents(receiveSubscription:receiveOutput:receiveCompletion:receiveCancel:receiveRequest:)` Performs the specified closures when publisher events occur.
  - receiveSubscription: An optional closure that executes when the publisher receives the subscription from the upstream publisher. This value defaults to nil.
  - receiveOutput: An optional closure that executes when the publisher receives a value from the upstream publisher. This value defaults to nil.
  - receiveCompletion: An optional closure that executes when the upstream publisher finishes normally or terminates with an error. This value defaults to nil.
  - receiveCancel: An optional closure that executes when the downstream receiver cancels publishing. This value defaults to nil.
  - receiveRequest: An optional closure that executes when the publisher receives a request for more elements. This value defaults to nil.
- https://developer.apple.com/documentation/combine/publisher/handleevents(receivesubscription:receiveoutput:receivecompletion:receivecancel:receiverequest:)
 */
final class HandlingEventsTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        cancellables = []
    }

    override func tearDown() {
        cancellables = nil

        super.tearDown()
    }

    func testHandleEventsOperator() {
        let publisher = (1...3).publisher

        publisher
            .handleEvents(receiveSubscription: { subscription in
                print("Subscription received: \(subscription.combineIdentifier)")
            }, receiveOutput: { intValue in
                print("in output handler, received \(intValue)")
            }, receiveCompletion: { _ in
                print("in completion handler")
            }, receiveCancel: {
                print("received cancel")
            }, receiveRequest: { (demand) in
                print("received demand: \(demand.description)")
            })
            .sink { _ in }
            .store(in: &cancellables)

        /*
         Prints:

         Subscription received: 0x6000004c3b80
         received demand: unlimited
         in output handler, received 1
         in output handler, received 2
         in output handler, received 3
         in completion handler
         */
    }
}
