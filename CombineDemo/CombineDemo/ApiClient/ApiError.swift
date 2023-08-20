//
//  ApiError.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation

struct ApiError {
    let reason: Reason
}

extension ApiError {
    enum Reason {
        case invalidRequest
        case invalidResponse
        case invalidStatus(code: Int)
        case decodingError(description: String)
        case unknownError(description: String)
    }
}

extension ApiError: Error {}
extension ApiError.Reason: Equatable {}
