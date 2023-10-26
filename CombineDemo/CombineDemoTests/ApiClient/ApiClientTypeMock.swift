//
//  ApiClientTypeMock.swift
//  CombineDemoTests
//
//  Created by Manish Rathi on 25/10/2023.
//

import Foundation
import Combine
@testable import CombineDemo

final class ApiClientTypeMock: ApiClientType {
    var loadEndpointCalled = false
    var receivedEndpoint: ApiEndpointType?
    var loadEndpointReturnValue: Decodable?
    var loadEndpointReturnError: CombineDemo.ApiError?

    func load<ApiModel>(endpoint: ApiEndpointType) -> AnyPublisher<ApiModel, CombineDemo.ApiError> where ApiModel: Decodable {
        loadEndpointCalled = true
        receivedEndpoint = endpoint

        if let returnValue = loadEndpointReturnValue {
            return Just(returnValue as! ApiModel)
                .setFailureType(to: CombineDemo.ApiError.self)
                .eraseToAnyPublisher()
        }

        guard let returnError = loadEndpointReturnError else {
            fatalError("Set value or error")
        }

        return Fail(error: returnError).eraseToAnyPublisher()
    }
}
