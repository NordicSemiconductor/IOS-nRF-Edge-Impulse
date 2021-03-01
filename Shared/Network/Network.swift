//
//  Internet.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation
import Combine

// MARK: - Network

final class Network {
    
    // MARK: - Properties
    
    public lazy var session = URLSession(configuration: .default)
    
    // MARK: - Singleton
    
    public static let shared = Network()
    
    private init() { }
}

// MARK: - API

extension Network {
    
    public func perform(_ request: APIRequest) -> AnyPublisher<Data, Error>? {
        guard let url = request.url() else { return nil }
        return session.dataTaskPublisher(for: request.urlRequest(url))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                return element.data
            }
            .eraseToAnyPublisher()
    }
}
