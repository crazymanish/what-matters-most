//
//  JSONLoader.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 25/10/2023.
//

import Foundation
@testable import CombineDemo

final class JSONLoader {
    static func data(forResourceName fixture: String) -> Data {
        let path = Bundle(for: JSONLoader.self).path(forResource: fixture, ofType: "json")!
        return FileManager.default.contents(atPath: path)!
    }
}

extension JSONDecoder {
    func example<T: Decodable>(data: Data) -> T {
        try! decode(T.self, from: data)
    }
}

extension Pokemon.ApiResponse {
    static var stubResponse: Pokemon.ApiResponse {
        let jsonData = JSONLoader.data(forResourceName: "PokemonList")
        return JSONDecoder.shared.example(data: jsonData)
    }
}
