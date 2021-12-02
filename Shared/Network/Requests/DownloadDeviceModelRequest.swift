//
//  DownloadDeviceModelRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import Foundation

extension HTTPRequest {
    
    static func downloadModelFor(project: Project, using projectApiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/deployment/download",
                                            parameters: ["type": "nordic-thingy53"]) else {
            return nil
        }
        
        httpRequest.setMethod(.GET)
        httpRequest.setHeaders(["x-api-key": projectApiToken, "Accept": "application/zip"])
        return httpRequest
    }
}
