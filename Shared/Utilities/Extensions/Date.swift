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
