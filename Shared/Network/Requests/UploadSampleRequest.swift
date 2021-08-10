//
//  UploadSampleRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/8/21.
//

import Foundation

extension HTTPRequest {
    
    static func uploadSample(_ fullSample: SamplingRequestFinishedResponse, category: DataSample.Category,
                             using apiToken: String) -> HTTPRequest? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .withoutEscapingSlashes
        guard var httpRequest = HTTPRequest(host: .EdgeImpulseIngestionAPI, path: "/api/\(category.rawValue)/data"),
              let bodyData = try? jsonEncoder.encode(fullSample) else {
            return nil
        }
        
        httpRequest.setMethod(.POST)
        let jwtValue = "jwt=" + apiToken
        httpRequest.setHeaders(["cookie": jwtValue, "Accept": "application/json"])
        httpRequest.setBody(bodyData)
        return httpRequest
    }
}
