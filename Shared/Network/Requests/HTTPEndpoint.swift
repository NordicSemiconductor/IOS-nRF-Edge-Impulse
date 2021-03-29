//
//  HTTPEndpoint.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 29/3/21.
//

import Foundation

// MARK: - Endpoint

struct HTTPEndpoint {
    
    let url: URL
    
    init?(host: HTTPHost, path: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host.rawValue
        components.path = path
        
        guard let url = components.url else { return nil }
        self.url = url
    }
}

// MARK: - Host

enum HTTPHost: String, RawRepresentable {
    
    case EdgeImpulse
    case GitHubUserContent
    
    var rawValue: String {
        switch self {
        case .EdgeImpulse:
            return "studio.edgeimpulse.com"
        case .GitHubUserContent:
            return "raw.githubusercontent.com"
        }
    }
}
