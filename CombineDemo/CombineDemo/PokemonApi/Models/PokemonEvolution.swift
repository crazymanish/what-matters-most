//
//  PokemonEvolution.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation

enum PokemonEvolution {}

extension PokemonEvolution {
    struct ApiResponse: Decodable {
        let chain: PokemonEvolution.ApiResponse.Chain?
    }
}

extension PokemonEvolution.ApiResponse {
    struct Chain: Decodable {
        let pokemon: Pokemon.ApiResponse.Info
        var evolvesTo: [PokemonEvolution.ApiResponse.Chain]?

        enum CodingKeys: String, CodingKey {
            case pokemon = "species"
            case evolvesTo
        }
    }
}

extension PokemonEvolution.ApiResponse.Chain: Equatable {}
extension PokemonEvolution.ApiResponse: Equatable {}

extension PokemonEvolution.ApiResponse.Chain {
    var canEvolve: Bool {
        guard let evolvesTo else { return false }
        return evolvesTo.count > 0
    }
}
