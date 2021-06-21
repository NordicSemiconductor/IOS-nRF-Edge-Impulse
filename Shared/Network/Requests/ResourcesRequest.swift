//
//  UUIDMappingsRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 29/3/21.
//

import Foundation

// MARK: - Request

extension HTTPRequest {
    
    static func getResourceStatus() -> HTTPRequest? {
        let path = "/repos/NordicSemiconductor/bluetooth-numbers-database/commits/master"
        guard var httpRequest = HTTPRequest(host: .GitHubAPI, path: path) else { return nil }
        httpRequest.setMethod(.GET)
        return httpRequest
    }
    
    static func getResource(_ resource: Resource) -> HTTPRequest? {
        guard var httpRequest = HTTPRequest(host: .GitHubUserContent, path: resource.path) else { return nil }
        httpRequest.setMethod(.GET)
        return httpRequest
    }
}

// MARK: - GitHubStatusResponse

struct GitHubStatusResponse: Codable {
    let sha: String
}

// MARK: - Resources Extension

fileprivate extension Resource {
    
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
