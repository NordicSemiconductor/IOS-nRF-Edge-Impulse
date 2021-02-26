//
//  LoginRequest.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation
import Combine

// MARK: - LoginRequest

struct LoginRequest: Request {
    typealias DataType = LoginParameters
    
    let url: URL
    let data: LoginParameters
    
    init?(_ parameters: LoginParameters) {
        self.data = parameters
        var components = URLComponents()
        components.scheme = "https"
        components.host = "studio.edgeimpulse.com"
        components.path = "/v\(API_VERSION)" + "/api-login"
        guard let url = components.url else { return nil }
        self.url = url
    }
}

// MARK: - LoginParameters

struct LoginParameters: Codable {
    let username: String
    let password: String
}
