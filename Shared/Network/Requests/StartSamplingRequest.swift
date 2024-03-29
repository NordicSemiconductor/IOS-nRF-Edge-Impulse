//
//  StartSamplingRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/6/21.
//

import Foundation
import iOS_Common_Libraries

extension HTTPRequest {
    
    static func startSampling(_ sampleMessage: SampleRequestMessage,
                              project: Project, device: Device,
                              using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/device/\(device.deviceId)/start-sampling"),
              let bodyData = try? JSONEncoder().encode(sampleMessage) else {
            return nil
        }
        
        httpRequest.setMethod(.POST)
        let jwtValue = "jwt=" + apiToken
        httpRequest.setHeaders(["cookie": jwtValue, "Accept": "application/json", "Content-Type": "application/json"])
        httpRequest.setBody(bodyData)
        return httpRequest
    }
}

// MARK: - Response

struct StartSamplingResponse: HTTPResponse {
    
    let id: Int
    let success: Bool
    let error: String?
}
