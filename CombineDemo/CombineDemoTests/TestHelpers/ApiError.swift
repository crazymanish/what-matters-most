//
//  ApiError.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 28/03/2023.
//

import Foundation

struct ApiError {
    let code: ApiError.Code

    init(code: ApiError.Code) {
        self.code = code
    }
}

extension ApiError {
    enum Code: Int {
        case notFound = 404
        case notImplemented = 501
    }
}

extension ApiError: Error {}
extension ApiError: Equatable {}
extension ApiError.Code: Equatable {}
