//
//  PokemonListViewModel.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation
import Combine

protocol PokemonListViewModelType: AnyObject {
    var pokemonResultsPublisher: Published<[Pokemon.ApiResponse.Result]>.Publisher { get }
    var apiErrorPublisher: Published<ApiError?>.Publisher { get }

    func fetchPokemons()
}


class PokemonListViewModel {
    lazy var apiClient: ApiClientType = ApiClient()
    lazy var cancellables: Set<AnyCancellable> = []

    var pokemonCount: Int = 0
    @Published var pokemonResults: [Pokemon.ApiResponse.Result] = []
    @Published var apiError: ApiError?
}

extension PokemonListViewModel: PokemonListViewModelType {
    var pokemonResultsPublisher: Published<[Pokemon.ApiResponse.Result]>.Publisher { $pokemonResults }
    var apiErrorPublisher: Published<ApiError?>.Publisher { $apiError }

    func fetchPokemons() {
        let endpoint = PokemonApiEndpoint.getList

        apiClient
            .get(endpoint: endpoint)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.apiError = error
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (response: Pokemon.ApiResponse) in
                self?.pokemonCount = response.count
                self?.pokemonResults = response.results
            }
            .store(in: &cancellables)
    }
}
