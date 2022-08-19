//
//  UploadSampleRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/8/21.
//

import Foundation
import iOS_Common_Libraries

extension HTTPRequest {
    
    static func uploadSample(_ headers: SamplingRequestFinishedResponse.Headers,
                             body: Data, name: String,
                             category: DataSample.Category) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulseIngestionAPI, path: "/api/\(category.rawValue)/data") else {
            return nil
        }
        
        var requestHeaders = [String: String]()
        requestHeaders["Content-Type"] = headers.contentType
        requestHeaders["x-api-key"] = headers.apiKey
        requestHeaders["x-label"] = headers.label
        requestHeaders["x-disallow-duplicates"] = headers.disallowDuplicates
        requestHeaders["x-file-name"] = name
        httpRequest.setMethod(.POST)
        httpRequest.setHeaders(requestHeaders)
        httpRequest.setBody(body)
        return httpRequest
    }
}
