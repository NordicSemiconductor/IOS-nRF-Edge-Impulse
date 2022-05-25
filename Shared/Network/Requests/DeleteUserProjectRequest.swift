//
//  DeleteUserProjectRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/5/22.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    
    static func deleteProject(_ projectId: Int, using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(projectId)") else { return nil }
        let jwtValue = "jwt=" + apiToken
        httpRequest.setMethod(.DELETE)
        httpRequest.setHeaders(["cookie": jwtValue])
        return httpRequest
    }
}

// MARK: - DeleteUserAPIResponse

struct DeleteUserProjectAPIResponse: APIResponse {
    
    let success: Bool
    let error: String?
}
