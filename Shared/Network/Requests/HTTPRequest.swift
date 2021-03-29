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
    
    init?(host: HTTPHost, path: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host.rawValue
        components.path = path
        
        guard let url = components.url else { return nil }
        self.init(url: url)
    }
    
    // MARK: - API
    
    mutating func setMethod(_ httpMethod: HTTPMethod) {
        switch httpMethod {
        case .GET(let headers):
            self.httpMethod = "GET"
            for (field, value) in headers {
                addValue(value, forHTTPHeaderField: field)
            }
        case .POST(let body):
            self.httpMethod = "POST"
            addValue("application/json", forHTTPHeaderField: "Content-Type")
            httpBody = body.data(using: .utf8)
        }
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

// MARK: - Method

enum HTTPMethod {
    case GET(headers: [String: String])
    case POST(body: String)
}

// MARK: - APIResponse

protocol APIResponse: Codable {
    
    var success: Bool { get }
    var error: String? { get }
}
