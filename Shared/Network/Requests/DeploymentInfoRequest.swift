//
//  DeploymentInfoRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 17/11/21.
//

import Foundation
import iOS_Common_Libraries

extension HTTPRequest {
    
    static func getDeploymentInfo(project: Project, using projectApiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/deployment",
                                            parameters: ["type": "nordic-thingy53"]) else { return nil }
        httpRequest.setMethod(.GET)
        httpRequest.setHeaders(["x-api-key": projectApiToken])
        return httpRequest
    }
}

// MARK: - Response

struct GetDeploymentInfoResponse: HTTPResponse {
    
    let success: Bool
    let error: String?
    
    let hasDeployment: Bool
}
