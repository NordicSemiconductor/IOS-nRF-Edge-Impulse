//
//  APIRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation

let API_VERSION = 1

// MARK: - Request

enum APIRequest {
    case httpGET(endpoint: String, headers: [String: String])
    case httpPOST(endpoint: String, body: String)
}

// MARK: - API

extension APIRequest {
    
    func url() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "studio.edgeimpulse.com"
        switch self {
        case .httpGET(let endpoint, _):
            components.path = "/v\(API_VERSION)" + "/\(endpoint)"
        case .httpPOST(let endpoint, _):
            components.path = "/v\(API_VERSION)" + "/\(endpoint)"
        }
       return components.url
    }
    
    func urlRequest(_ url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        switch self {
        case .httpGET(_, let headers):
            urlRequest.httpMethod = "GET"
            for (field, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: field)
            }
        case .httpPOST(_, let body):
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = body.data(using: .utf8)
        }
        return urlRequest
    }
}

// MARK: - APIResponse

protocol APIResponse: Codable {
    
    var success: Bool { get }
    var error: String? { get }
}
