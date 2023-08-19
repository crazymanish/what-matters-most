//
//  Pokemon.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation

enum Pokemon {}

extension Pokemon {
    struct ApiResponse: Decodable {
        let count: Int
        let results: [Pokemon.ApiResponse.Result]
    }
}

extension Pokemon.ApiResponse {
    struct Result: Decodable {
        let name: String
        let url: URL
    }
}

extension Pokemon.ApiResponse.Result: Equatable {}
extension Pokemon.ApiResponse: Equatable {}
