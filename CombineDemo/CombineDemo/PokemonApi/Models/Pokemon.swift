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

extension Pokemon.ApiResponse.Result {
    private enum Constants {
        static let imageURLPath = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"
    }

    var pokemonID: Int? { Int(url.lastPathComponent) }

    var capitalizedName: String { name.capitalized }

    var imageURL: URL? {
        guard let pokemonID else { return nil }

        let imageURLString = Constants.imageURLPath + "\(pokemonID).png"

        return URL(string: imageURLString)
    }
}
