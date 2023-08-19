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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pokemon list"
        view.backgroundColor = .systemBackground

        setUpBindings()
        viewModel.fetchPokemons()
    }

    private func setUpBindings() {
        viewModel
            .pokemonResultsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pokemonResults in
                self?.pokemons = pokemonResults
                // TODO: Reload TableView data
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
