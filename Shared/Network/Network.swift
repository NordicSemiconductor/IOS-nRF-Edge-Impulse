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
    
    public func perform<T: Codable>(_ request: URLRequest, responseType: T.Type = T.self) -> AnyPublisher<T, Error>? {
        return session.dataTaskPublisher(for: request)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if httpResponse.statusCode == 401 {
                    throw URLError(.userAuthenticationRequired)
                }
                return element.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
