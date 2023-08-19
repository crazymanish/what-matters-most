//
//  DefaultError.swift
//  CombineDemo
//
//  Created by Manish Rathi on 31/03/2023.
//

import Foundation
import Combine

/// - `DefaultError` is a custom publisher that immediately terminates with the specified error.
/// - It works exactly same as Apple's built-in `Fail` publisher
/// - https://developer.apple.com/documentation/combine/fail
struct DefaultError<Output, Failure>: Publisher where Failure: Error {
    let error: Failure

    init(error: Failure) {
        self.error = error
    }

    func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = Subscription(error: error, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private extension DefaultError {
    final class Subscription<S: Subscriber> where S.Input == Output, S.Failure == Failure {
        private let error: Failure
        private var subscriber: S?

        init(error: Failure, subscriber: S) {
            self.error = error
            self.subscriber = subscriber
        }

        func cancel() {
            subscriber = nil
        }

        func request(_ demand: Subscribers.Demand) {
            subscriber?.receive(completion: .failure(error))
        }
    }
}

extension DefaultError.Subscription : Cancellable {}
extension DefaultError.Subscription : Subscription {}
