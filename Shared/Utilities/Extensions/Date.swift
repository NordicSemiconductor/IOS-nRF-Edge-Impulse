//
//  Date.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 28/4/21.
//

import Foundation

extension Date {
    
    static func currentYear() -> Int {
        guard let calendar = NSCalendar(calendarIdentifier: .gregorian) else {
            fatalError("Failed call to NSCalendar with Gregorian Calendar.")
        }
        return calendar.component(.year, from: Date())
    }
}

// MARK: - Format

extension Date {
    
    func formatterString(dateStyle: DateFormatter.Style = .short, timeStyle: DateFormatter.Style = .short) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        
        return dateFormatter.string(from: self)
    }
}
