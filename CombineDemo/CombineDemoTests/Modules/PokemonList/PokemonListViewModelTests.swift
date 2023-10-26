//
//  PokemonListViewModel.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 25/10/2023.
//

import Foundation
import Combine
import XCTest
@testable import CombineDemo

final class PokemonListViewModelTests: XCTestCase {
    var apiClient: ApiClientTypeMock!
    var subject: PokemonListViewModel!

    override func setUp() {
        super.setUp()

        apiClient = ApiClientTypeMock()

        subject = PokemonListViewModel()
        subject.apiClient = apiClient
    }

    override func tearDown() {
        apiClient = nil
        subject = nil

        super.tearDown()
    }

    func testEndpointForPokemonListApi() {
        // Given
        apiClient.loadEndpointReturnValue = Pokemon.ApiResponse.stubResponse

        // When
        subject.fetchPokemons()

        // Then
        let receivedEndpoint = apiClient.receivedEndpoint as? PokemonApiEndpoint
        XCTAssertEqual(receivedEndpoint, .getList(offset: 0, limit: 20))
    }

    func testEndpointValueResponseForPokemonListApi() {
        // Given
        let stubResponse = Pokemon.ApiResponse.stubResponse
        apiClient.loadEndpointReturnValue = stubResponse

        // When
        subject.fetchPokemons()

        // Then
        XCTAssertEqual(subject.pokemons, stubResponse.pokemons)
        XCTAssertEqual(subject.allPokemonsCount, stubResponse.count)
        XCTAssertEqual(subject.currentPage, 1) // Bump the page value
        XCTAssertNil(subject.apiError)
    }

    func testEndpointErrorResponseForPokemonListApi() {
        // Given
        let stubError = CombineDemo.ApiError(reason: .invalidRequest)
        apiClient.loadEndpointReturnError = stubError

        // When
        subject.fetchPokemons()

        // Then
        XCTAssertEqual(subject.apiError, stubError)
        XCTAssertEqual(subject.pokemons, [])
        XCTAssertEqual(subject.allPokemonsCount, 0)
        XCTAssertEqual(subject.currentPage, 0) // No Bump in the page value
    }

    func testEndpointForPokemonListApiWhenCurrentPageIsLastPage() {
        // Given
        subject.currentPage = Pokemon.ApiResponse.stubResponse.count

        // When
        subject.fetchPokemons()

        // Then
        XCTAssertFalse(subject.canFetchPokemons)
        XCTAssertFalse(apiClient.loadEndpointCalled) // Do not even call endpoint
    }
}
