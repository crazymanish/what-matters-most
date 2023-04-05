//
//  JSONDecodingTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 05/04/2023.
//

import Foundation
import Combine
import XCTest

final class JSONDecodingTests: XCTestCase {
    var urlSession: URLSession!
    var publisher: AnyPublisher<GitHubUser, Error>!
    var cancellables: Set<AnyCancellable>!
    var receivedError: Error?

    override func setUp() {
        super.setUp()

        let apiURL = URL(string: "https://api.github.com/users/crazymanish")
        urlSession = URLSession.shared
        publisher = urlSession.dataTaskPublisher(with: apiURL!)
        cancellables = []
    }

    override func tearDown() {
        urlSession = nil
        publisher = nil
        cancellables = nil
        receivedError = nil

        super.tearDown()
    }

    func testURLSessionPublisher() {
        let expectation = XCTestExpectation(description: "Fetching GitHub user info")

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                self?.receivedError = error
                XCTFail("Received error: \(error)")
                expectation.fulfill()
            }
        } receiveValue: { gitHubUser in
            XCTAssertEqual(gitHubUser.login, "crazymanish")
            XCTAssertEqual(gitHubUser.name, "Manish Rathi")

            expectation.fulfill()
        }
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }
}

struct GitHubUser: Decodable {
    let name: String
    let login: String
}
