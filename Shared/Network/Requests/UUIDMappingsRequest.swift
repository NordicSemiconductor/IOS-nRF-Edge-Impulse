//
//  UUIDMappingsRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 29/3/21.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    
    static func getResource(_ resource: Resources) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .GitHubUserContent, path: resource.path) else { return nil }
        httpRequest.setMethod(.GET(headers: [:]))
        return httpRequest
    }
}

// MARK: - Resources Extension

fileprivate extension Resources {
    
    var path: String {
        let basePath = "/NordicSemiconductor/bluetooth-numbers-database/master/v1/"
        let resourceFile: String
        switch self {
        case .services:
            resourceFile = "service_uuids.json"
        case .characteristics:
            resourceFile = "characteristic_uuids.json"
        case .descriptors:
            resourceFile = "descriptor_uuids.json"
        }
        return basePath + resourceFile
    }
}
