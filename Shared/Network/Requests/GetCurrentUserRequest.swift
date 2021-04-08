//
//  GetCurrentUserRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    
    static func getUser(using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/user") else { return nil }
        let jwtValue = "jwt=" + apiToken
        httpRequest.setMethod(.GET(header: ["cookie": jwtValue]))
        return httpRequest
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
    
    // MARK: - API
    
    func getUser() -> User? {
        guard let createdDate = created.formatAsDate() else { return nil }
        return User(id: id, username: username, created: createdDate, photo: photo)
    }
}
