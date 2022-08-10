//
//  Date.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 28/4/21.
//

import Foundation

// MARK: - Format

extension Date {
    
    func formatterString(dateStyle: DateFormatter.Style = .short, timeStyle: DateFormatter.Style = .short) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        
        return dateFormatter.string(from: self)
    }
}
