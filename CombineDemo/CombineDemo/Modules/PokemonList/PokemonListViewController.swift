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

    private enum Constants {
        static let height: CGFloat = 116
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PokemonTableViewCell.self)
        tableView.separatorColor = .clear
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
            .sink { [weak self] in self?.handleResponse($0) }
            .store(in: &cancellables)

        viewModel
            .apiErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.handleError($0) }
            .store(in: &cancellables)
    }

    private func handleResponse(_ pokemons: [Pokemon.ApiResponse.Result]) {
        self.pokemons = pokemons

        tableView.reloadData()
    }

    private func handleError(_ apiError: ApiError?) {
        // TODO: Show Error
    }
}

extension PokemonListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PokemonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.selectionStyle = .none
        cell.configure(for: pokemons[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.height
    }
}

extension PokemonListViewController: UITableViewDelegate {}
