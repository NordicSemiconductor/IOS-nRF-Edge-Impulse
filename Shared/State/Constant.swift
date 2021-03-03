//
//  Constant.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/3/21.
//

import Foundation

// MARK: - Constant

enum Constant {
    
    // MARK: - URL(s)
    
    static let signupURL: URL! = URL(string: "https://studio.edgeimpulse.com/signup")
    static let forgottenPasswordURL: URL! = URL(string: "https://studio.edgeimpulse.com/forgot-password")
    
    // MARK: - String(s)
    
    static let copyrightString: String! = {
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearString = NumberFormatter().string(from: NSNumber(value: currentYear))
        return "Copyright © \(yearString ?? "2021") Nordic Semiconductor ASA"
    }()
}
