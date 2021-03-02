//
//  Project.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import Foundation

// MARK: - Project

struct Project: Codable {
    let id: Int
    let name: String
    let description: String
    let createdString: String
    let owner: String
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case createdString = "created"
        
        case id, name, description, owner
    }
    
    // MARK: - API
    
    func createdDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdString)
    }
}
