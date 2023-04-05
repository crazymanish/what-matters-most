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
    enum Code {
        case notFound
        case notImplemented
        case httpStatus(code: Int)

        var value: Int {
            switch self {
            case .notFound: return 404
            case .notImplemented: return 501
            case .httpStatus(code: let code): return code
            }
        }
    }
}

extension ApiError: Error {}
extension ApiError: Equatable {}
extension ApiError.Code: Equatable {}
