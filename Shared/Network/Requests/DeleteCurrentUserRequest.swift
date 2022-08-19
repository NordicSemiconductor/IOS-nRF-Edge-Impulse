//
//  DeleteCurrentUserRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/5/22.
//

import Foundation
import iOS_Common_Libraries

// MARK: - Request

extension HTTPRequest {
    
    static func deleteUser(_ userId: Int, using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/users/\(userId)") else { return nil }
        let jwtValue = "jwt=" + apiToken
        httpRequest.setMethod(.DELETE)
        httpRequest.setHeaders(["cookie": jwtValue])
        return httpRequest
    }
}

// MARK: - DeleteUserAPIResponse

struct DeleteUserAPIResponse: HTTPResponse {
    
    let success: Bool
    let error: String?
}
