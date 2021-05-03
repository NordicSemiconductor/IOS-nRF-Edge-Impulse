//
//  GetProjectDevelopmentKeysRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/5/21.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    
    static func getProjectDevelopmentKeys(for project: Project, using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/devkeys") else { return nil }
        let jwtValue = "jwt=" + apiToken
        httpRequest.setMethod(.GET(header: ["cookie": jwtValue]))
        return httpRequest
    }
}

// MARK: - Response

struct ProjectDevelopmentKeysResponse: APIResponse {
    
    let success: Bool
    let error: String?
    
    let apiKey: String
    let hmacKey: String
}
