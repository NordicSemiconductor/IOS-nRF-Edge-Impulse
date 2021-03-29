//
//  HTTPRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation

// MARK: - Request

enum HTTPMethod {
    case GET(headers: [String: String])
    case POST(body: String)
}

// MARK: - URLRequest

extension URLRequest {
    
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

// MARK: - APIResponse

protocol APIResponse: Codable {
    
    var success: Bool { get }
    var error: String? { get }
}
