//
//  User.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import Foundation

// MARK: - User

struct User: Identifiable, Codable {
    
    // MARK: Static
    
    static let NoImage = ""
    static let PlaceholderImage = "https://avatars.githubusercontent.com/u/52098900?s=200&v=4" // Edge Impulse Logo
    
    private static let NameFormatter: PersonNameComponentsFormatter = {
        let nameFormatter = PersonNameComponentsFormatter()
        nameFormatter.style = .medium
        return nameFormatter
    }()
    
    // MARK: Properties
    
    let id: Int
    let username: String
    let created: Date
    let createdSince: String
    let photo: URL
    let mfaConfigured: Bool
    
    private let name: String
    private let nameComponents: PersonNameComponents?
    
    // MARK: - Init
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let username = try container.decode(String.self, forKey: .username)
        let name = try container.decode(String.self, forKey: .name)
        let photo = try container.decode(String.self, forKey: .photo)
        let mfaConfigured = try container.decode(Bool.self, forKey: .mfaConfigured)
        
        let createdString = try container.decode(String.self, forKey: .created)
        guard let created = createdString.formatAsDate() else {
            throw DecodingError.dataCorruptedError(forKey: .created, in: container,
                                                   debugDescription: "`Created` Date String does not match expected format.")
        }
        self.init(id: id, username: username, name: name, created: created, photo: photo,
                  mfaConfigured: mfaConfigured)
    }
    
    init(id: Int, username: String, name: String, created: Date, photo: String = NoImage,
         mfaConfigured: Bool) {
        self.id = id
        self.username = username
        self.name = name
        self.created = created
        self.photo = URL(string: photo == User.NoImage ? User.PlaceholderImage : photo)!
        self.mfaConfigured = mfaConfigured
        
        if #available(iOS 15.0, macOS 12.0, *) {
            self.nameComponents = try? PersonNameComponents(name)
        } else {
            self.nameComponents = nil
        }
        
        let relativeDateFormatter = RelativeDateTimeFormatter()
        self.createdSince = relativeDateFormatter.localizedString(for: created, relativeTo: Date())
    }
    
    var formattedName: String {
        guard let nameComponents = nameComponents else { return name }
        return User.NameFormatter.string(from: nameComponents)
    }
}

// MARK: - Hashable, Equatable

extension User: Hashable, Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
