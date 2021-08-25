//
//  MacAddress.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 24/8/21.
//

import Foundation

final class MacAddress {
    
    static let shared = MacAddress()
    
    // MARK: - Private
    
    private init() {}
    
    /**
     macOS counterpart is properly implemented.
     */
    func get() -> String? {
        return nil
    }
}
