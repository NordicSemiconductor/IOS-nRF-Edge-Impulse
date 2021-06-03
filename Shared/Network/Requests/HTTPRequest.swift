//
//  HTTPRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation

// MARK: - HTTPRequest

typealias HTTPRequest = URLRequest

extension HTTPRequest {
    
    // MARK: - Init
    
    init?(host: HTTPHost, path: String, parameters: [String: String]? = nil) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host.rawValue
        components.path = path
        components.queryItems = parameters?.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components.url else { return nil }
        self.init(url: url)
    }
    
    // MARK: - API
    
    mutating func setMethod(_ httpMethod: HTTPMethod) {
        self.httpMethod = httpMethod.rawValue
    }
    
    mutating func setHeaders(_ headers: [String : String]) {
        for (field, value) in headers {
            addValue(value, forHTTPHeaderField: field)
        }
    }
    
    mutating func setBody(_ data: Data) {
        addValue("application/json", forHTTPHeaderField: "Content-Type")
        httpBody = data
    }
}

// MARK: - Host

enum HTTPHost: String, RawRepresentable {
    
    case EdgeImpulse
    case GitHubAPI
    case GitHubUserContent
    
    var rawValue: String {
        switch self {
        case .EdgeImpulse:
            return "studio.edgeimpulse.com"
        case .GitHubAPI:
            return "api.github.com"
        case .GitHubUserContent:
            return "raw.githubusercontent.com"
        }
    }
}

// MARK: - Method

enum HTTPMethod: String, RawRepresentable {
    
    case GET, POST
}

// MARK: - APIResponse

protocol APIResponse: Codable {
    
    var success: Bool { get }
    var error: String? { get }
}
