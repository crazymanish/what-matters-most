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

        let successHandler: (Pokemon.ApiResponse) -> Void = { [weak self] in
            self?.pokemonCount = $0.count
            self?.pokemonResults = $0.results
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
}

extension Subscribers.Completion<ApiError> {
    var error: ApiError? {
        guard case .failure(let error) = self else { return nil }

        return error
    }
}
