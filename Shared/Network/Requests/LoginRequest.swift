//
//  LoginRequest.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation
import Combine

// MARK: - LoginRequest

extension APIRequest {
    
    static func login(_ parameters: LoginParameters) -> APIRequest? {
        guard let bodyData = try? JSONEncoder().encode(parameters),
              let bodyString = String(data: bodyData, encoding: .utf8) else { return nil }
        return .httpPOST(endpoint: "api-login", body: bodyString)
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
