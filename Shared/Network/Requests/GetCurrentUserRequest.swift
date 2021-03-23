//
//  GetCurrentUserRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import Foundation

extension APIRequest {
    
    static func getUser(using apiToken: String) -> APIRequest {
        let jwtValue = "jwt=" + apiToken
        return .httpGET(endpoint: "api/user", headers: ["cookie": jwtValue])
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
    
    // MARK: - User
    
    func user() -> User? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        guard let createdDate = formatter.date(from: created) else { return nil }
        return User(id: id, username: username, created: createdDate)
    }
}
