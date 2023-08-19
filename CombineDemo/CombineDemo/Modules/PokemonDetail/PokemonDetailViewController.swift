//
//  PokemonDetailViewController.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import UIKit
import Combine

class PokemonDetailViewController: PokemonBaseViewController {
    lazy var viewModel: PokemonDetailViewModelType = PokemonDetailViewModel()
    lazy var evolvedPokemons: [Pokemon.ApiResponse.Result] = []
    var pokemonDetail: PokemonDetail.ApiResponse?

    let pokemon: Pokemon.ApiResponse.Result

    init(pokemon: Pokemon.ApiResponse.Result) {
        self.pokemon = pokemon
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupBindings()

        guard let pokemonID = pokemon.pokemonID else { return }

        viewModel.fetchPokemonDetail(pokemonID: pokemonID)
    }

    private func setupView() {
        title = pokemon.capitalizedName + "'s evolution"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    private func setupBindings() {
        viewModel
            .pokemonDetailPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] in self?.handlePokemonDetailResponse($0) }
            .store(in: &cancellables)

        viewModel
            .evolvedPokemonsPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] in self?.handlePokemonEvolutionResponse($0) }
            .store(in: &cancellables)

        viewModel
            .apiErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.handleError($0) }
            .store(in: &cancellables)
    }

    private func handlePokemonDetailResponse(_ pokemonDetail: PokemonDetail.ApiResponse?) {
        self.pokemonDetail = pokemonDetail
    }

    private func handlePokemonEvolutionResponse(_ evolvedPokemons: [Pokemon.ApiResponse.Result]) {
        self.evolvedPokemons = evolvedPokemons

        self.tableView.reloadData()
    }
}

extension PokemonDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return evolvedPokemons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PokemonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.selectionStyle = .none
        cell.configure(for: evolvedPokemons[indexPath.row], pokemonColor: pokemonDetail?.color.uiColor)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.height
    }
}

extension PokemonDetailViewController: UITableViewDelegate {}
