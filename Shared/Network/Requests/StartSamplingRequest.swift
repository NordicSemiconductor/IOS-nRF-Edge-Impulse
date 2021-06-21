//
//  StartSamplingRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/6/21.
//

import Foundation

extension HTTPRequest {
    
    static func startSampling(_ sampleMessage: SampleRequestMessage, project: Project, device: RegisteredDevice,
                              using apiToken: String) -> HTTPRequest? {
        #warning("Use RegisteredDevice here.")
        let deviceId = device.id
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/device/\(deviceId)/start-sampling"),
              let bodyData = try? JSONEncoder().encode(sampleMessage) else {
            return nil
        }
        
        httpRequest.setMethod(.POST)
        let jwtValue = "jwt=" + apiToken
        httpRequest.setHeaders(["cookie": jwtValue, "Accept": "application/json"])
        httpRequest.setBody(bodyData)
        return httpRequest
    }
}

// MARK: - Response

struct StartSamplingResponse: APIResponse {
    
    let id: Int
    let success: Bool
    let error: String?
}
