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
    
    static func deleteUser(with parameters: DeleteUserParameters,
                           using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/user/"),
              let bodyData = try? JSONEncoder().encode(parameters) else { return nil }
        
        let jwtValue = "jwt=" + apiToken
        httpRequest.setMethod(.DELETE)
        httpRequest.setHeaders(["cookie": jwtValue])
        httpRequest.setHeaders(["Content-Type": "application/json"])
        httpRequest.setBody(bodyData)
        return httpRequest
    }
}

// MARK: - DeleteUserParameters

struct DeleteUserParameters: Codable {
    let password: String
    let totpToken: String?
    
    init(password: String, totpToken: String? = nil) {
        self.password = password
        self.totpToken = totpToken
    }
}

// MARK: - DeleteUserAPIResponse

struct DeleteUserAPIResponse: HTTPResponse {
    
    let success: Bool
    let error: String?
}
