//
//  PokemonBaseViewController.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import UIKit
import Combine

class PokemonBaseViewController: UIViewController {
    lazy var cancellables: Set<AnyCancellable> = []

    enum Constants {
        static let height: CGFloat = 116
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PokemonTableViewCell.self)
        tableView.separatorColor = .clear
        return tableView
    }()
}
