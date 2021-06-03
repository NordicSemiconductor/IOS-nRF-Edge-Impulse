//
//  Device.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import Foundation
import CoreBluetooth.CBPeripheral

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

/// `ScanResult` represents discovered device by Scanner
struct Device: Identifiable {
    enum State {
        case notConnected
        case connecting
        case ready // Connected and ready for use
        
        var isReady: Bool {
            if case .ready = self {
                return true
            } else {
                return false
            }
        }
        
    }
    
    let name: String
    let id: UUID
    let rssi: RSSI
    let advertisementData: AdvertisementData
    var state: State = .notConnected
    
    init(name: String, id: UUID, rssi: RSSI, advertisementData: AdvertisementData) {
        self.name = name
        self.id = id
        self.rssi = rssi
        self.advertisementData = advertisementData
    }
    
    init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        self.advertisementData = AdvertisementData(advertisementData)
        self.rssi = RSSI(value: rssi.intValue)
        self.name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "N/A"
        self.id = peripheral.identifier
    }
    
    var isConnectedAndReadyForUse: Bool {
        switch state {
        case .ready:
            return true
        default:
            return false
        }
    }
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - DeviceScanResult
extension Device: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Device.State: CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
        case .notConnected:
            return "notConnected"
        case .connecting:
            return "connecting"
        case .ready:
            return "ready"
        }
    }
}

// MARK: - Sample
#if DEBUG
extension Device {
    static let sample = Device(name: "Test Device", id: UUID(), rssi: .outOfRange, advertisementData: .mock)
}
#endif
