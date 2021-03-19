//
//  Device.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import Foundation

struct Device: Identifiable, Hashable {
    
    let id: UUID
}

extension Device {
    static let Dummy = Device(id: UUID())
}
