//
//  PokemonListViewController.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import UIKit
import Combine

class PokemonListViewController: UIViewController {
    lazy var viewModel: PokemonListViewModelType = PokemonListViewModel()
    lazy var cancellables: Set<AnyCancellable> = []
    lazy var pokemons: [Pokemon.ApiResponse.Result] = []

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PokemonTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupBindings()
        viewModel.fetchPokemons()
    }

    private func setupView() {
        title = "Pokemon list"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    private func setupBindings() {
        viewModel
            .pokemonResultsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pokemonResults in
                self?.pokemons = pokemonResults
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel
            .apiErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { error in
                print(error as Any) // TODO: Show Error
            }
            .store(in: &cancellables)
    }
}

extension PokemonListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PokemonTableViewCell.reuseIdentifier, for: indexPath)
        cell.selectionStyle = .none

        let name = pokemons[indexPath.row].name
        cell.textLabel?.text = name.capitalized
        return cell
    }
}

extension PokemonListViewController: UITableViewDelegate {}
