//
//  LoginRequest.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation
import Combine
import iOS_Common_Libraries

// MARK: - LoginRequest

extension HTTPRequest {
    
    static func login(_ parameters: LoginParameters) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api-login"),
              let bodyData = try? JSONEncoder().encode(parameters) else { return nil }
        
        httpRequest.setMethod(.POST)
        httpRequest.setHeaders(["Content-Type": "application/json"])
        httpRequest.setBody(bodyData)
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
    let error: String?
    
    let token: String?
}
