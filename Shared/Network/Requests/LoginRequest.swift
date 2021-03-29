//
//  LoginRequest.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation
import Combine

// MARK: - LoginRequest

extension HTTPEndpoint {
    
    static func login(_ parameters: LoginParameters) -> URLRequest? {
        let endpoint = HTTPEndpoint(host: .EdgeImpulse, path: "/v1/api-login")
        guard let url = endpoint.url(),
              let bodyData = try? JSONEncoder().encode(parameters),
              let bodyString = String(data: bodyData, encoding: .utf8) else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setMethod(.POST(body: bodyString))
        return urlRequest
    }
}

// MARK: - LoginParameters

struct LoginParameters: Codable {
    let username: String
    let password: String
}

// MARK: - LoginResponse

struct LoginResponse: Codable {
    let success: Bool
    let token: String?
    let error: String?
}
