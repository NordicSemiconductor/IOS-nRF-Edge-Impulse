//
//  User.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import Foundation

struct User: Identifiable {
    
    let id: Int
    let username: String
    let created: Date
    let createdSince: String
    
    // MARK: - Init
    
    init?(response: GetUserResponse) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        guard let createdDate = formatter.date(from: response.created) else { return nil }
        self.init(id: response.id, username: response.username, created: createdDate)
    }
    
    init(id: Int, username: String, created: Date) {
        self.id = id
        self.username = username
        self.created = created
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        self.createdSince = String(format: formatter.string(from: created, to: Date()) ?? "N/A", locale: .current)
    }
}
