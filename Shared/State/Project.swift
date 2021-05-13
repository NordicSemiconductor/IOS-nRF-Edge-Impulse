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
    let logo: URL
    let collaborators: [User]
    
    // MARK: - Init
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.owner = try container.decode(String.self, forKey: .owner)
        if let logoString = try? container.decode(String.self, forKey: .logo),
           let logoURL = URL(string: logoString) {
            self.logo = logoURL
        } else {
            self.logo = URL(string: User.PlaceholderImage)!
        }
        self.collaborators = try container.decode([User].self, forKey: .collaborators)
        
        let createdString = try container.decode(String.self, forKey: .created)
        guard let createdDate = createdString.formatAsDate() else {
            throw DecodingError.dataCorruptedError(forKey: .created, in: container,
                          debugDescription: "`Created` Date String does not match expected format.")
        }
        self.created = createdDate
    }
}

// MARK: - Hashable

extension Project: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Sample Project

extension Project {
    
    static let Unselected: Project! = try? JSONDecoder().decode(Project.self, from: UnselectedProjectJSON.data(using: .utf8)!)
    static let UnselectedProjectJSON = """
            {
                "id": 0,
                "name": "--",
                "description": "None.",
                "created": "2021-02-26T10:55:47.731Z",
                "owner": "nRF Edge Impulse",
                "collaborators": []
            }
    """
    
    #if DEBUG
    static let Sample: Project! = try? JSONDecoder().decode(Project.self, from: SampleJSON.data(using: .utf8)!)
    static let SampleJSON = """
        {
            "id": 595,
            "name": "Sample",
            "description": "This is just a sample.",
            "created": "2021-02-26T10:55:47.731Z",
            "owner": "Pongo Harjani",
            "collaborators": [
                {
                    "id": 1989,
                    "username": "taylor.swift",
                    "created": "1989-12-13T10:55:47.731Z",
                    "createdSince": "1989",
                    "photo": "https://avatarfiles.alphacoders.com/169/169651.jpg"
                },
                {
                    "id": 1981,
                    "username": "fernando.alonso",
                    "created": "1981-07-29T10:55:47.731Z",
                    "createdSince": "1981",
                    "photo": "https://live.planetf1.com/content/images/uploads/drivers/profile/2021/195077.jpg"
                }
            ]
        }
    """
    #endif
}
