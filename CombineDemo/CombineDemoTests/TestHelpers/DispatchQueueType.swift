//
//  DispatchQueueType.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 28/03/2023.
//

import Foundation

protocol DispatchQueueType: AnyObject {
    func asyncAfter(
        deadline: DispatchTime,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping @convention(block) () -> Void)
}

extension DispatchQueueType {
    func asyncAfter(
        deadline: DispatchTime,
        execute work: @escaping @convention(block) () -> Void) {
        asyncAfter(deadline: deadline, qos: .unspecified, flags: [], execute: work)
    }
}

extension DispatchQueue: DispatchQueueType {}

final class DispatchQueueMock: DispatchQueueType {
    var deadline: DispatchTime?
    var execute: (() -> Void)?

    func asyncAfter(
        deadline: DispatchTime,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute work: @escaping @convention(block) () -> Void) {
        self.deadline = deadline
        self.execute = work
    }
}
