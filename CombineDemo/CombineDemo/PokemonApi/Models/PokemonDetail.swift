//
//  PokemonDetail.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation
import UIKit

enum PokemonDetail {}

extension PokemonDetail {
    struct ApiResponse: Decodable {
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

extension PokemonDetail.ApiResponse.EvolutionChain {
    var chainID: Int? { Int(url.lastPathComponent) }
}

extension PokemonDetail.ApiResponse.Color {
    var uiColor: UIColor {
        switch name {
        case "black": return .black
        case "darkGray": return .darkGray
        case "lightGray": return .lightGray
        case "white": return .white
        case "gray": return .gray
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "cyan": return .cyan
        case "yellow": return .yellow
        case "magenta": return .magenta
        case "orange": return .orange
        case "purple": return .purple
        case "brown": return .brown
        default: return .systemBackground
        }
    }
}
