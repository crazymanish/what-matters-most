//
//  NetworkingTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 12/08/2023.
//

import Foundation
import Combine
import XCTest

final class NetworkingTests: XCTestCase {
    var urlSession: URLSession!
    var publisher: URLSession.DataTaskPublisher!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedError: Error?

    override func setUp() {
        super.setUp()

        let apiURL = URL(string: "https://api.github.com/users/crazymanish")
        urlSession = URLSession.shared
        publisher = urlSession.dataTaskPublisher(for: apiURL!)
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        urlSession = nil
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil
        receivedError = nil

        super.tearDown()
    }

    func testURLSessionPublisher() {
        let expectation = XCTestExpectation(description: "Fetching GitHub user info")

        publisher.sink { [weak self] completion in
            guard let self else { return }

            switch completion {
            case .finished:
                self.isFinishedCalled = true
            case .failure(let error):
                self.receivedError = error
            }

            XCTAssertTrue(self.isFinishedCalled)
            XCTAssertNil(self.receivedError)
            expectation.fulfill()
        } receiveValue: { apiResponse in
            let jsonResponse = try? JSONSerialization.jsonObject(with: apiResponse.data, options: []) as? [String: Any]
            XCTAssertEqual(jsonResponse?["login"] as? String, "crazymanish")
            XCTAssertEqual(jsonResponse?["name"] as? String, "Manish Rathi")
        }
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }

    func testURLSessionPublisherWithCodable() {
        let expectation = XCTestExpectation(description: "Fetching GitHub user info")

        publisher
            .tryMap { data, _ in
                try JSONDecoder().decode(GitHubUser.self, from: data)
            }
            .sink { [weak self] completion in
            guard let self else { return }

            switch completion {
            case .finished:
                self.isFinishedCalled = true
            case .failure(let error):
                self.receivedError = error
            }

            XCTAssertTrue(self.isFinishedCalled)
            XCTAssertNil(self.receivedError)
            expectation.fulfill()
        } receiveValue: { gitHubUser in
            XCTAssertEqual(gitHubUser.login, "crazymanish")
            XCTAssertEqual(gitHubUser.name, "Manish Rathi")
        }
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }

    func testURLSessionPublisherWithCodableWithAnotherWay() {
        let expectation = XCTestExpectation(description: "Fetching GitHub user info")

        // The only advantage is that you instantiate the JSONDecoder only once, when setting up the publisher, v/s creating it every time in the tryMap(_:) closure.
        publisher
            .map(\.data)
            .decode(type: GitHubUser.self, decoder: JSONDecoder())
            .sink { [weak self] completion in
            guard let self else { return }

            switch completion {
            case .finished:
                self.isFinishedCalled = true
            case .failure(let error):
                self.receivedError = error
            }

            XCTAssertTrue(self.isFinishedCalled)
            XCTAssertNil(self.receivedError)
            expectation.fulfill()
        } receiveValue: { gitHubUser in
            XCTAssertEqual(gitHubUser.login, "crazymanish")
            XCTAssertEqual(gitHubUser.name, "Manish Rathi")
        }
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }
}
