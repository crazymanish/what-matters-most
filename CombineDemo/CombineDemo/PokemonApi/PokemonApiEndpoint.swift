//
//  PokemonApiEndpoint.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation

enum PokemonApiEndpoint: ApiEndpointType {
    case getList(offset: Int, limit: Int)
    case getDetail(pokemonID: Int)
    case getEvolutionChain(chainID: Int)

    var path: String {
        switch self {
        case .getList:
            return "/api/v2/pokemon-species"
        case .getDetail(let pokemonID):
            return "/api/v2/pokemon-species/\(pokemonID)"
        case .getEvolutionChain(let chainID):
            return "/api/v2/evolution-chain/\(chainID)"
        }
    }

    var queryParameters: [String : String]? {
        switch self {
        case .getList(let offset, let limit):
            return [
                "offset": "\(offset)",
                "limit": "\(limit)"
            ]
        default: return nil
        }
    }
}
