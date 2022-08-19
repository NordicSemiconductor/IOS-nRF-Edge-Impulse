//
//  GetCurrentUserRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import Foundation
import iOS_Common_Libraries

// MARK: - Request

extension HTTPRequest {
    
    static func getUser(using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/user") else { return nil }
        let jwtValue = "jwt=" + apiToken
        httpRequest.setMethod(.GET)
        httpRequest.setHeaders(["cookie": jwtValue])
        return httpRequest
    }
}

// MARK: - Response

struct GetUserResponse: HTTPResponse {
    let success: Bool
    let error: String?
    
    // MARK: - Data
    
    let user: User
    let projects: [Project]
    
    // MARK: - Init
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decode(Bool.self, forKey: .success)
        self.error = try? container.decode(String.self, forKey: .error)
        self.projects = try container.decode([Project].self, forKey: .projects)
        
        let singleValueContainer = try decoder.singleValueContainer()
        self.user = try singleValueContainer.decode(User.self)
    }
}
