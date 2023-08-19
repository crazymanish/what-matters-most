//
//  PokemonTableViewCell.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import UIKit

class PokemonTableViewCell: UITableViewCell {}

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension PokemonTableViewCell: Reusable {}
