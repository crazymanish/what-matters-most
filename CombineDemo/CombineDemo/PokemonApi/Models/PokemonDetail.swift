//
//  PokemonDetail.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation

enum PokemonDetail {}

extension PokemonDetail {
    struct ApiResponse: Decodable {
        let name: String
        let color: PokemonDetail.ApiResponse.Color
        let evolutionChain: PokemonDetail.ApiResponse.EvolutionChain?
    }
}

extension PokemonDetail.ApiResponse {
    struct EvolutionChain: Decodable {
        let url: URL
    }
}

extension PokemonDetail.ApiResponse {
    struct Color: Decodable {
        let name: String
    }
}

extension PokemonDetail.ApiResponse.Color: Equatable {}
extension PokemonDetail.ApiResponse.EvolutionChain: Equatable {}
extension PokemonDetail.ApiResponse: Equatable {}
