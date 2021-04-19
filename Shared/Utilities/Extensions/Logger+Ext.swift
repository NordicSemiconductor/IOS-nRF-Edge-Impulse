//
//  Logger+Ext.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Nick Kibysh on 12/04/2021.
//

import Foundation
import os

extension Logger {
   
    static let EdgeImpulseSubsystem = "com.nordicsemi.nRF-Edge-Impulse"
    
    // MARK: - Init
    
    init(_ clazz: AnyClass) {
        self.init(category: String(describing: clazz))
    }
    
    init(category: String) {
        self.init(subsystem: Logger.EdgeImpulseSubsystem, category: category)
    }
}
