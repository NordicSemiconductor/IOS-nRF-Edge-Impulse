//
//  GetSocketTokenRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 1/7/21.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    
    static func getSocketToken(for project: Project, using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/socket-token") else { return nil }
        httpRequest.setMethod(.GET)
        httpRequest.setHeaders(["x-api-key": apiToken])
        return httpRequest
    }
}

// MARK: - Response

struct GetSocketTokenResponse: APIResponse {
    
    let success: Bool
    let error: String?
    
    let token: Token
}

struct Token: Codable {
    
    let socketToken: String
    let expires: String
}
