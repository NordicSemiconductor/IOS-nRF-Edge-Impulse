//
//  DeploymentInfoRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 17/11/21.
//

import Foundation

extension HTTPRequest {
    
    static func getDeploymentInfo(project: Project, using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/deployment",
                                            parameters: ["type": "nordic-thingy53"]) else { return nil }
        httpRequest.setMethod(.GET)
        let jwtValue = "jwt=" + apiToken
        httpRequest.setHeaders(["cookie": jwtValue])
        return httpRequest
    }
}

// MARK: - Response

struct GetDeploymentInfoResponse: APIResponse {
    
    let success: Bool
    let error: String?
    
    let hasDeployment: Bool
}
