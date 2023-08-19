//
//  ApiError.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation

struct ApiError {
    let failure: Failure
}

extension ApiError {
    enum Failure {
        case invalidRequest
        case invalidResponse
        case invalidStatus(code: Int)
        case decodingError(description: String)
        case unknownError(description: String)
    }
}

extension ApiError: Error {}
extension ApiError.Failure: Equatable {}
