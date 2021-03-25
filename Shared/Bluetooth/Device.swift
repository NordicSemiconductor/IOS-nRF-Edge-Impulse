//
//  Device.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import Foundation

// MARK: - RSSI

enum RSSI: Int {
    case outOfRange = 127
    case practicalWorst = -100
    case bad
    case ok
    case good
    
    init(value: Int) {
        switch value {
        case (5)... : self = .outOfRange
        case (-60)...(-20): self = .good
        case (-89)...(-20): self = .ok
        default: self = .bad
        }
    }
}

// MARK: - Device
    
struct Device: Identifiable {
    let name: String
    let id: UUID
    let rssi: RSSI
}

// MARK: - Device.Hashable

extension Device: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Sample

extension Device {
    static let sample = Device(name: "Test Device", id: UUID(), rssi: .outOfRange)
}
