//
//  LoginRequest.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation
import Combine

// MARK: - LoginRequest

extension HTTPRequest {
    
    static func login(_ parameters: LoginParameters) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api-login"),
              let bodyData = try? JSONEncoder().encode(parameters),
              let bodyString = String(data: bodyData, encoding: .utf8) else { return nil }
        
        httpRequest.setMethod(.POST(body: bodyString))
        return httpRequest
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
