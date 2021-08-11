//
//  UploadSampleRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/8/21.
//

import Foundation

extension HTTPRequest {
    
    static func uploadSample(_ headers: SamplingRequestFinishedResponse.Headers, body: Data, name: String,
                             category: DataSample.Category) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulseIngestionAPI, path: "/api/\(category.rawValue)/data") else {
            return nil
        }
        
        httpRequest.setMethod(.POST)
        var requestHeaders: [String : String] = ["content-type": "application/cbor"]
        requestHeaders["x-api-key"] = headers.apiKey
        requestHeaders["x-label"] = headers.label
        requestHeaders["x-disallow-duplicates"] = headers.disallowDuplicates
        requestHeaders["x-file-name"] = name
        httpRequest.setHeaders(requestHeaders)
        httpRequest.setBody(body)
        return httpRequest
    }
}
