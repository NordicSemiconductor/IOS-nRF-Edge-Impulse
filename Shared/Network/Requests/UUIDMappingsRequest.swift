//
//  UUIDMappingsRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 29/3/21.
//

import Foundation

// MARK: - Endpoint

extension HTTPEndpoint {
    
    static func getResource(_ resource: Resources) -> URLRequest? {
        let endpoint = HTTPEndpoint(host: .GitHubUserContent, path: resource.path)
        guard let url = endpoint.url() else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.setMethod(.GET(headers: [:]))
        return urlRequest
    }
}

// MARK: - Resources Extension

fileprivate extension Resources {
    
    var path: String {
        let basePath = "/NordicSemiconductor/bluetooth-numbers-database/master/v1/"
        let resourceFile: String
        switch self {
        case .serviceUUIDs:
            resourceFile = "service_uuids.json"
        }
        return basePath + resourceFile
    }
}
