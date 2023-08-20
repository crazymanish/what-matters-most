//
//  ApiClient.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation
import Combine

class ApiClient {
    let baseURLString: String
    let urlSession: URLSession
    let jsonDecoder: JSONDecoder

    init(
        baseURLString: String = "https://pokeapi.co/",
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = .shared) {
        self.baseURLString = baseURLString
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
}

extension ApiClient: ApiClientType {
    func get<ApiModel: Decodable>(endpoint: ApiEndpointType) -> AnyPublisher<ApiModel, ApiError> {
        guard let apiRequest = endpoint.asURLRequest(baseURLString: baseURLString) else {
            let error = ApiError(reason: .invalidRequest)
            return Fail(error: error).eraseToAnyPublisher()
        }

        return execute(request: apiRequest)
    }

    private func execute<ApiModel: Decodable>(request: URLRequest) -> AnyPublisher<ApiModel, ApiError> {
        urlSession
            .dataTaskPublisher(for: request)
            .tryMap { (data: Data, response: URLResponse) in
                try response.validate()
                return data
            }
            .decode(type: ApiModel.self, decoder: jsonDecoder)
            .mapError { self.map(error: $0) }
            .eraseToAnyPublisher()
    }

    private func map(error: Error) -> ApiError {
        let description = error.localizedDescription

        switch error {
        case is DecodingError:
            return ApiError(reason: .decodingError(description: description))
        case let error as ApiError:
            return error
        default:
            return ApiError(reason: .unknownError(description: description))
        }
    }
}

private extension URLResponse {
    func validate() throws {
        let httpURLResponse = self as? HTTPURLResponse

        guard let httpURLResponse else {
            throw ApiError(reason: .invalidResponse)
        }

        let statusCode = httpURLResponse.statusCode

        guard (200...299).contains(statusCode) else {
            throw ApiError(reason: .invalidStatus(code: statusCode))
        }
    }
}
