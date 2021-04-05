//
//  User.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import Foundation

struct User: Identifiable, Codable {
    
    static let PlaceholderImage = ""
    
    // MARK: - Properties
    
    let id: Int
    let username: String
    let created: Date
    let createdSince: String
    
    // MARK: - Init
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let username = try container.decode(String.self, forKey: .username)
        
        let createdString = try container.decode(String.self, forKey: .created)
        guard let created = createdString.formatAsDate() else {
            throw DecodingError.dataCorruptedError(forKey: .created, in: container,
                                                   debugDescription: "`Created` Date String does not match expected format.")
        }
        self.init(id: id, username: username, created: created)
    }
    
    init(id: Int, username: String, created: Date) {
        self.id = id
        self.username = username
        self.created = created
        
        let relativeDateFormatter = RelativeDateTimeFormatter()
        self.createdSince = relativeDateFormatter.localizedString(for: created, relativeTo: Date())
    }
}

// MARK: - Hashable

extension User: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
