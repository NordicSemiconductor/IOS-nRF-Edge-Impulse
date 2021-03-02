//
//  ListProjectsRequest.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 1/3/21.
//

import Foundation

extension APIRequest {
    
    static func listProjects(_ apiToken: String) -> APIRequest {
        let jwtValue = "jwt=" + apiToken
        return .httpGET(endpoint: "api/projects", headers: ["cookie": jwtValue])
    }
}

// MARK: - Response

struct ProjectsResponse: Codable {
    let success: Bool
    let error: String?
    let projects: [Project]
}
