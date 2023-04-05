//
//  URLSession+Decodable.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 05/04/2023.
//

import Foundation
import Combine

extension URLSession {
    func dataTaskPublisher<T: Decodable>(with url: URL) -> AnyPublisher<T, Error> {
        return self
            .dataTaskPublisher(for: url)
            .tryMap { (data, response) in
                if let httpResponse = response as? HTTPURLResponse,
                   (200..<300).contains(httpResponse.statusCode) == false {
                    let code = ApiError.Code.httpStatus(code: httpResponse.statusCode)
                    throw ApiError(code: code)
                }

                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
