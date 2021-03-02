//
//  Project.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import Foundation

// MARK: - Project

struct Project: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let created: Date
    let owner: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.owner = try container.decode(String.self, forKey: .owner)
        
        let createdString = try container.decode(String.self, forKey: .created)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        guard let createdDate = formatter.date(from: createdString) else {
            throw DecodingError.dataCorruptedError(forKey: .created, in: container,
                          debugDescription: "`Created` Date String does not match expected format.")
        }
        self.created = createdDate
    }
}

// MARK: - Sample Project

extension Project {
    
    static let Sample: Project! = try? JSONDecoder().decode(Project.self, from: SampleJSON.data(using: .utf8)!)
    
    static let SampleJSON = """
    {
        "id": 595,
        "name": "Sample",
        "description": "This is just a sample.",
        "created": "2021-02-26T10:55:47.731Z",
        "owner": "Pongo Harjani"
    }
    """
}
