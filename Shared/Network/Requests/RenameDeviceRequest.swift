//
//  RenameDeviceRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/7/21.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    
    static func renameDevice(_ device: Device, as newName: String, in project: Project, using apiToken: String) -> HTTPRequest? {
        guard var request = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/devices/\(device.deviceId)/rename"),
              let bodyData = try? JSONEncoder().encode(RenameDeviceBody(name: newName)) else { return nil }
        
        request.setMethod(.POST)
        let jwtValue = "jwt=" + apiToken
        request.setHeaders(["cookie": jwtValue, "Accept": "application/json"])
        request.setBody(bodyData)
        return request
    }
}

// MARK: - RenameDeviceBody

fileprivate struct RenameDeviceBody: Codable {
    
    let name: String
}

// MARK: - Response

struct RenameDeviceResponse: APIResponse {
    
    let success: Bool
    let error: String?
}
