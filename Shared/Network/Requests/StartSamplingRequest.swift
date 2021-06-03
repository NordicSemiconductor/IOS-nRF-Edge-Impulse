//
//  StartSamplingRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/6/21.
//

import Foundation

extension HTTPRequest {
    
    static func startSampling(_ sampleMessage: SampleRequestMessage, project: Project, device: Device) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/device/\(device.id)"),
              let bodyData = try? JSONEncoder().encode(sampleMessage),
              let bodyString = String(data: bodyData, encoding: .utf8) else {
            return nil
        }
        
        httpRequest.setMethod(.POST(body: bodyString))
        return httpRequest
    }
}

// MARK: - Response

struct StartSamplingResponse: APIResponse {
    
    let id: Int
    let success: Bool
    let error: String?
}
