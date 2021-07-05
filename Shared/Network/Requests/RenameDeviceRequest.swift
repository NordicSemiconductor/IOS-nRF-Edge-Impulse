//
//  RenameDeviceRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/7/21.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    
    static func renameDevice(_ deviceId: Int, as newName: String, in project: Project, using apiToken: String) -> HTTPRequest? {
        var request = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/devices/\(deviceId)/rename)",
                                  parameters: ["name": newName])
        let jwtValue = "jwt=" + apiToken
        request?.setMethod(.POST)
        request?.setHeaders(["cookie": jwtValue])
        return request
    }
}

// MARK: - Response

struct RenameDeviceResponse: APIResponse {
    
    let success: Bool
    let error: String?
}
