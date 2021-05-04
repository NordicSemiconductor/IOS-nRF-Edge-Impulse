//
//  GetSamplesRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/5/21.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    
    static func getSamples(for project: Project, in category: DataSample.Category, using apiToken: String) -> HTTPRequest? {
        let parameters = ["category": category.rawValue]
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/raw-data",
                                            parameters: parameters) else { return nil }
        httpRequest.setMethod(.GET(header: ["x-api-key": apiToken]))
        return httpRequest
    }
}

// MARK: - Response

struct GetSamplesResponse: APIResponse {
    
    let success: Bool
    let error: String?
    
    let samples: [DataSample]
}
