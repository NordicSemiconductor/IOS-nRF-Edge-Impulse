//
//  Logger+Ext.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Nick Kibysh on 12/04/2021.
//

import Foundation
import os

extension Logger {
    static let ei = Logger(subsystem: "com.nordicsemi.nRF-Edge-Impulse", category: "Default")
    
    init(category: String) {
        self.init(subsystem: "com.nordicsemi.nRF-Edge-Impulse", category: category)
    }
}
