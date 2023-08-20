//
//  PokemonDetailViewModel.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation
import Combine

protocol PokemonDetailViewModelType: AnyObject {
    var pokemonDetailPublisher: Published<PokemonDetail.ApiResponse?>.Publisher { get }
    var evolvedPokemonsPublisher: Published<[Pokemon.ApiResponse.Info]>.Publisher { get }
    var apiErrorPublisher: Published<ApiError?>.Publisher { get }

    func fetchPokemonDetail(pokemonID: Int)
}

class PokemonDetailViewModel {
    lazy var apiClient: ApiClientType = ApiClient()
    lazy var cancellables: Set<AnyCancellable> = []

    @Published var pokemonDetail: PokemonDetail.ApiResponse?
    @Published var evolvedPokemons: [Pokemon.ApiResponse.Info] = []
    @Published var apiError: ApiError?
}

extension PokemonDetailViewModel: PokemonDetailViewModelType {
    var pokemonDetailPublisher: Published<PokemonDetail.ApiResponse?>.Publisher { $pokemonDetail }
    var evolvedPokemonsPublisher: Published<[Pokemon.ApiResponse.Info]>.Publisher { $evolvedPokemons }
    var apiErrorPublisher: Published<ApiError?>.Publisher { $apiError }

    func fetchPokemonDetail(pokemonID: Int) {
        let endpoint = PokemonApiEndpoint.getDetail(pokemonID: pokemonID)

        let successHandler: (PokemonDetail.ApiResponse) -> Void = { [weak self] in
            self?.pokemonDetail = $0
            self?.fetchPokemonEvolutionChain($0)
        }

        let errorHandler: (ApiError?) -> Void = { [weak self] in
            self?.apiError = $0
        }

        apiClient
            .get(endpoint: endpoint)
            .sink { errorHandler($0.error)
            } receiveValue: { successHandler($0) }
            .store(in: &cancellables)
    }

    private func fetchPokemonEvolutionChain(_ pokemonDetail: PokemonDetail.ApiResponse) {
        guard let evolutionChain = pokemonDetail.evolutionChain else { return }
        guard let evolutionChainID = evolutionChain.chainID else { return }

        let endpoint = PokemonApiEndpoint.getEvolutionChain(chainID: evolutionChainID)

        let successHandler: (PokemonEvolution.ApiResponse) -> Void = { [weak self] in
            guard let self else { return }
            self.evolvedPokemons = self.flattenEvolutionChain($0.chain)
        }

        let errorHandler: (ApiError?) -> Void = { [weak self] in
            self?.apiError = $0
        }

        apiClient
            .get(endpoint: endpoint)
            .sink { errorHandler($0.error)
            } receiveValue: { successHandler($0) }
            .store(in: &cancellables)
    }

    private func flattenEvolutionChain(_ chain: PokemonEvolution.ApiResponse.Chain?) -> [Pokemon.ApiResponse.Info] {
        guard let chain else { return [] }
        guard chain.canEvolve else { return [chain.pokemon] }

        return [chain.pokemon] + flattenEvolutionChain(chain.evolvesTo?[0]) // Considering: Only 1 evolves-into...
    }
}
