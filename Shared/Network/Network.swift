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
    
    public func perform<R: Request>(_ request: R) -> AnyPublisher<Data, Error> {
        return session.dataTaskPublisher(for: request.urlRequest())
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
