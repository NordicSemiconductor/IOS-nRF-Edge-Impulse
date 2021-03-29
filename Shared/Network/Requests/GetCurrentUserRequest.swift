//
//  GetCurrentUserRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import Foundation

extension HTTPEndpoint {
    
    static func getUser(using apiToken: String) -> URLRequest? {
        guard let endpoint = HTTPEndpoint(host: .EdgeImpulse, path: "/v1/api/user") else { return nil }
        
        var urlRequest = URLRequest(url: endpoint.url)
        let jwtValue = "jwt=" + apiToken
        urlRequest.setMethod(.GET(headers: ["cookie": jwtValue]))
        return urlRequest
    }
}

// MARK: - Response

struct GetUserResponse: APIResponse {
    let success: Bool
    let error: String?
    
    // MARK: - Data
    
    let id: Int
    let username: String
    let photo: String
    let created: String
    let projects: [Project]
}
