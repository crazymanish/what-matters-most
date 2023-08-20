//
//  PokemonListViewModel.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation
import Combine

protocol PokemonListViewModelType: AnyObject {
    var pokemonsPublisher: Published<[Pokemon.ApiResponse.Info]>.Publisher { get }
    var apiErrorPublisher: Published<ApiError?>.Publisher { get }

    func fetchPokemons()
}

class PokemonListViewModel {
    lazy var apiClient: ApiClientType = ApiClient()
    lazy var cancellables: Set<AnyCancellable> = []

    let pageSize = 20
    var currentPage = 0
    var allPokemonsCount = 0
    @Published var pokemons: [Pokemon.ApiResponse.Info] = []
    @Published var apiError: ApiError?

    var offset: Int { currentPage * pageSize }

    var canFetchPokemons: Bool {
        if currentPage == 0 { return true }
        return offset+pageSize < allPokemonsCount
    }
}

extension PokemonListViewModel: PokemonListViewModelType {
    var pokemonsPublisher: Published<[Pokemon.ApiResponse.Info]>.Publisher { $pokemons }
    var apiErrorPublisher: Published<ApiError?>.Publisher { $apiError }

    func fetchPokemons() {
        guard canFetchPokemons else { return }

        let endpoint = PokemonApiEndpoint.getList(offset: offset, limit: pageSize)

        let successHandler: (Pokemon.ApiResponse) -> Void = { [weak self] in
            self?.pokemons = $0.pokemons
            self?.allPokemonsCount = $0.count
            self?.currentPage += 1
        }

        let errorHandler: (ApiError?) -> Void = { [weak self] in
            self?.apiError = $0
        }

        apiClient
            .load(endpoint: endpoint)
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
