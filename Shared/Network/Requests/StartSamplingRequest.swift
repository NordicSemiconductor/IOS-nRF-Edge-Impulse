//
//  StartSamplingRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/6/21.
//

import Foundation

extension HTTPRequest {
    
    static func startSampling(_ sampleMessage: SampleRequestMessage, project: Project, device: Device,
                              using apiToken: String) -> HTTPRequest? {
        #warning("Use RegisteredDevice here.")
        let deviceId = "phone_kp6z2nxu"
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/device/\(deviceId)/start-sampling"),
              let bodyData = try? JSONEncoder().encode(sampleMessage),
              let bodyString = String(data: bodyData, encoding: .utf8) else {
            return nil
        }
        
//        httpRequest.setMethod(.GET(header: ["x-api-key": apiToken]))
        let jwtValue = "jwt=" + apiToken
        httpRequest.setMethod(.GET(header: ["cookie": jwtValue]))
        let body = """
            {"category":"training","intervalMs":16,"label":"WednesdayBeforeLunch","lengthMs":10000,"sensor":"Accelerometer"}
            """
        httpRequest.setMethod(.POST(body: body))
        return httpRequest
    }
}

// MARK: - Response

struct StartSamplingResponse: APIResponse {
    
    let id: Int
    let success: Bool
    let error: String?
}
