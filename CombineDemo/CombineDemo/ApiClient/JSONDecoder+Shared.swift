//
//  JSONDecoder+Shared.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation

extension JSONDecoder {
    static let shared: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
