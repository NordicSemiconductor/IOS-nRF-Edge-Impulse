//
//  DeleteDeviceRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 16/7/21.
//

import Foundation

// MARK: - Delete Device Request

extension HTTPRequest {
    
    static func deleteDevice(_ device: Device, from project: Project, using apiToken: String) -> HTTPRequest? {
        guard var request = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/device/\(device.deviceId)") else {
            return nil
        }
        
        request.setMethod(.DELETE)
        let jwtValue = "jwt=" + apiToken
        request.setHeaders(["cookie": jwtValue, "Accept": "application/json"])
        return request
    }
}

// MARK: - Response

struct DeleteDeviceResponse: APIResponse {
    
    let success: Bool
    let error: String?
}
