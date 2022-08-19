//
//  HTTPHost.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 19/8/22.
//

import Foundation
import iOS_Common_Libraries

// MARK: - HTTPHost

enum HTTPHost: String, RawRepresentable {

    case EdgeImpulse
    case EdgeImpulseIngestionAPI
    case GitHubAPI
    case GitHubUserContent

    var rawValue: String {
        switch self {
        case .EdgeImpulse:
            return "studio.edgeimpulse.com"
        case .EdgeImpulseIngestionAPI:
            return "ingestion.edgeimpulse.com"
        case .GitHubAPI:
            return "api.github.com"
        case .GitHubUserContent:
            return "raw.githubusercontent.com"
        }
    }
}

// MARK: - HTTPRequest

extension HTTPRequest {
    
    init?(scheme: HTTPScheme = .https, host: HTTPHost, path: String, parameters: [String: String]? = nil) {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host.rawValue
        components.path = path
        components.queryItems = parameters?.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components.url else { return nil }
        self.init(url: url)
    }
}
