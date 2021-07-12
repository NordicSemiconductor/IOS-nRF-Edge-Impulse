//
//  DownloadDeviceModelRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import Foundation

extension HTTPRequest {
    
    static func downloadModelFor(project: Project, using apiToken: String) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .EdgeImpulse, path: "/v1/api/\(project.id)/deployment/download",
                                            parameters: ["type": "nordic-thingy53"]) else {
            return nil
        }
        
        httpRequest.setMethod(.GET)
        let jwtValue = "jwt=" + apiToken
        httpRequest.setHeaders(["cookie": jwtValue, "Accept": "application/json"])
        return httpRequest
    }
}
