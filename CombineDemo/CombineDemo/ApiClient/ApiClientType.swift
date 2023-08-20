//
//  ApiClientType.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import Foundation
import Combine

protocol ApiClientType {
    func load<ApiModel: Decodable>(endpoint: ApiEndpointType) -> AnyPublisher<ApiModel, ApiError>
}
