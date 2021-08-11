//
//  UploadSampleRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/8/21.
//

import Foundation

extension HTTPRequest {
    
    static func uploadSample(_ fullSample: SamplingRequestFinishedResponse, name: String,
                             category: DataSample.Category, using apiToken: String) -> HTTPRequest? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        guard var httpRequest = HTTPRequest(host: .EdgeImpulseIngestionAPI, path: "/api/\(category.rawValue)/data"),
              let bodyData = try? jsonEncoder.encode(fullSample) else {
            return nil
        }
        
        httpRequest.setMethod(.POST)
        var headers: [String : String] = ["Accept": "*/*", "Accept-Encoding": "gzip, deflate, br",
                                          "Content-Type": "application/json"]
        headers["x-api-key"] = fullSample.headers.apiKey
        headers["x-label"] = fullSample.headers.label
        headers["x-disallow-duplicates"] = fullSample.headers.disallowDuplicates
        headers["x-file-name"] = name
        httpRequest.setHeaders(headers)
        httpRequest.setBody(bodyData)
        return httpRequest
    }
}
