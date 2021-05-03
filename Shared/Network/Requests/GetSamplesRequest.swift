//
//  GetSamplesRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/5/21.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    
    static func getSamples(for project: Project, in category: GetSamplesResponse.Category, using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/raw-data") else { return nil }
        let jwtValue = "jwt=" + apiToken
        httpRequest.setMethod(.GET(header: ["cookie": jwtValue, "category": category.rawValue]))
        return httpRequest
    }
}

// MARK: - Response

struct GetSamplesResponse: APIResponse {
    
    let success: Bool
    let error: String?
    
//    let samples: [DataSample]
}

// MARK: - GetSamplesResponse.Category

extension GetSamplesResponse {
    
    enum Category: String, RawRepresentable {
        case training, testing, anomaly
    }
}
