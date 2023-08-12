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

    func testURLSessionPublisherWithMultipleSubscribers() {
        let expectation = XCTestExpectation(description: "Fetching GitHub user info")

        let apiURL = URL(string: "https://api.github.com/users/crazymanish")
        let publisher = urlSession
            .dataTaskPublisher(for: apiURL!)
            .map(\.data)
            .multicast {
                PassthroughSubject<Data, URLError>()
            }

        let publisher1 = publisher
            .decode(type: GitHubUser.self, decoder: JSONDecoder())
        let publisher2 = publisher
            .decode(type: GitHubUser.self, decoder: JSONDecoder())

        // Subscription1
        publisher1
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
        } receiveValue: { gitHubUser in
            XCTAssertEqual(gitHubUser.login, "crazymanish")
            XCTAssertEqual(gitHubUser.name, "Manish Rathi")

            print("CAME here")
        }
        .store(in: &cancellables)

        // Subscription2
        publisher2
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
        } receiveValue: { gitHubUser in
            XCTAssertEqual(gitHubUser.login, "crazymanish")
            XCTAssertEqual(gitHubUser.name, "Manish Rathi")

            print("CAME here too")
        }
        .store(in: &cancellables)

        // Ensuring that both both publishers received the correct values
        publisher1
            .zip(publisher2)
            .sink(receiveCompletion: { [weak self] _ in
                self?.isFinishedCalled = true
            }, receiveValue: { gitHubUser1, gitHubUser2 in
                XCTAssertEqual(gitHubUser1.login, "crazymanish")
                XCTAssertEqual(gitHubUser1.name, "Manish Rathi")

                XCTAssertEqual(gitHubUser2.login, "crazymanish")
                XCTAssertEqual(gitHubUser2.name, "Manish Rathi")

                print("CAME here too too")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        // Connect the publisher, when we are ready. It will start working and pushing values to all of its subscribers.
        publisher
            .connect()
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }
}
