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
