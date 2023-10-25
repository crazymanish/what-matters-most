//
//  ApiEndpoint.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
}

protocol ApiEndpointType {
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var bodyParameters: [String: Any]? { get }
}

// Defaults
extension ApiEndpointType {
    var httpMethod: HTTPMethod { return .get }
    var headers: [String: String]? { return nil }
    var queryParameters: [String: String]? { return nil }
    var bodyParameters: [String: Any]? { return nil }
}

extension ApiEndpointType {
    func asURLRequest(baseURLString: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURLString) else { return nil }
        urlComponents.path += path
        urlComponents.queryItems = queryItems

        guard let apiURL = urlComponents.url else { return nil }

        var urlRequest = URLRequest(url: apiURL)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = httpBody
        return urlRequest
    }

    private var queryItems: [URLQueryItem] {
        guard let queryParameters else { return [] }
        return queryParameters.map { URLQueryItem(name: $0, value: $1) }
    }

    private var httpBody: Data? {
        guard let bodyParameters else { return nil }
        return try? JSONSerialization.data(withJSONObject: bodyParameters)
    }
}
