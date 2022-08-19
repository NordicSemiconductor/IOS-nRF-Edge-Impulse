//
//  Network.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 19/8/22.
//

import Foundation
import iOS_Common_Libraries

extension Network {
    
    // MARK: - Singleton
    
    public static let shared = Network(HTTPHost.EdgeImpulse.rawValue)
}
