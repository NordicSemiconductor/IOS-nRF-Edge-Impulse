//
//  HTTPEndpoint.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 29/3/21.
//

import Foundation

// MARK: - Endpoint

struct HTTPEndpoint {
    
    let host: HTTPHost
    let path: String
    
    func url() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host.rawValue
        components.path = path
        return components.url
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
