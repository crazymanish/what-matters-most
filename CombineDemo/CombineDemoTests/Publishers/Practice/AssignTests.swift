//
//  AssignTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 06/04/2023.
//

import Foundation
import Combine
import XCTest

final class AssignTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        cancellables = []
    }

    override func tearDown() {
        cancellables = nil

        super.tearDown()
    }

    func testAssign() {
        let user = User()

        ["Manish rathi"]
            .publisher
            .assign(to: \.name, on: user)
            .store(in: &cancellables)

        XCTAssertEqual(user.name, "Manish rathi")
    }
}

class User {
    var name: String = "James bond"
}
