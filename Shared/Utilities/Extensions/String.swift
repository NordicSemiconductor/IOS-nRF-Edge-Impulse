//
//  String.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 5/4/21.
//

import Foundation

extension String {
    
    var uppercasingFirst: String {
        prefix(1).uppercased() + dropFirst()
    }
    
    func formatAsDate() -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        return dateFormatter.date(from: self)
    }
}

// MARK: - String + Date
extension String {
    func toDate(_ format: String? = nil) -> Date? {
        if let f = format {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = f
            return dateFormatter.date(from: self)
        } else {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return dateFormatter.date(from: self)
        }
    }
}
