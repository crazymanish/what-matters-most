//
//  PokemonApiEndpoint.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation

enum PokemonApiEndpoint: ApiEndpointType {
    case getList
    case getDetail(pokemonID: Int)

    var path: String {
        switch self {
        case .getList:
            return "/api/v2/pokemon-species"
        case .getDetail(let pokemonID):
            return "/api/v2/pokemon-species/\(pokemonID)"
        }
    }
}
