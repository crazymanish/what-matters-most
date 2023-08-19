//
//  DefaultValue.swift
//  CombineDemo
//
//  Created by Manish Rathi on 31/03/2023.
//

import Foundation
import Combine

/// - `DefaultValue` is a custom publisher that emits an output to each subscriber just once, and then finishes.
/// - It works exactly same as Apple's built-in `Just` publisher
/// - https://developer.apple.com/documentation/combine/just/
struct DefaultValue<Output>: Publisher {
    typealias Failure = Never

    let output: Output

    init(_ output: Output) {
        self.output = output
    }

    func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = Subscription(output: output, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private extension DefaultValue {
    final class Subscription<S: Subscriber> where S.Input == Output, S.Failure == Failure {
        private let output: Output
        private var subscriber: S?

        init(output: Output, subscriber: S) {
            self.output = output
            self.subscriber = subscriber
        }

        func cancel() {
            subscriber = nil
        }

        func request(_ demand: Subscribers.Demand) {
            _ = subscriber?.receive(output)
            _ = subscriber?.receive(completion: .finished)
        }
    }
}

extension DefaultValue.Subscription : Cancellable {}
extension DefaultValue.Subscription : Subscription {}
