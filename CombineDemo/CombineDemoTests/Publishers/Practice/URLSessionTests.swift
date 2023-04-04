//
//  URLSessionTests.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 03/04/2023.
//

import Foundation
import Combine
import XCTest

final class URLSessionTests: XCTestCase {
    var urlSession: URLSession!
    var publisher: URLSession.DataTaskPublisher!
    var cancellables: Set<AnyCancellable>!
    var isFinishedCalled: Bool!
    var receivedData: Data?
    var receivedError: Error?

    override func setUp() {
        super.setUp()

        let apiURL = URL(string: "https://api.github.com/users/crazymanish")
        let urlRequest = URLRequest(url: apiURL!)
        urlSession = URLSession.shared
        publisher = URLSession.DataTaskPublisher(request: urlRequest, session: urlSession)
        cancellables = []
        isFinishedCalled =  false
    }

    override func tearDown() {
        urlSession = nil
        publisher = nil
        cancellables = nil
        isFinishedCalled = nil
        receivedData = nil
        receivedError = nil

        super.tearDown()
    }

    func testURLSessionPublisher() {
        let expectation = XCTestExpectation(description: "Fetching GitHub user info")

        publisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                self?.isFinishedCalled = true
            case .failure(let error):
                self?.receivedError = error
            }
        } receiveValue: { [weak self] apiResponse in
            self?.receivedData = apiResponse.data

            let jsonResponse = try? JSONSerialization.jsonObject(with: apiResponse.data, options: []) as? [String: Any]
            XCTAssertEqual(jsonResponse?["login"] as? String, "crazymanish")
            XCTAssertEqual(jsonResponse?["name"] as? String, "Manish Rathi")

            expectation.fulfill()
        }
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }
}
