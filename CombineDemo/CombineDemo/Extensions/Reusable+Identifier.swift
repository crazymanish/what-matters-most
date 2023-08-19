//
//  Reusable+Identifier.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable {}
