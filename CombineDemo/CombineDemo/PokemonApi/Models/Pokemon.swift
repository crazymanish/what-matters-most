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
        let pokemons: [Pokemon.ApiResponse.Info]

        enum CodingKeys: String, CodingKey {
            case count
            case pokemons = "results"
        }
    }
}

extension Pokemon.ApiResponse {
    struct Info: Decodable {
        let name: String
        let url: URL
    }
}

extension Pokemon.ApiResponse.Info: Equatable {}
extension Pokemon.ApiResponse: Equatable {}

extension Pokemon.ApiResponse.Info {
    private enum Constants {
        static let imageURLPath = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"
    }

    var capitalizedName: String { name.capitalized }

    var pokemonID: Int? { Int(url.lastPathComponent) }

    var imageURL: URL? {
        guard let pokemonID else { return nil }

        let imageURLString = Constants.imageURLPath + "\(pokemonID).png"
        return URL(string: imageURLString)
    }
}
