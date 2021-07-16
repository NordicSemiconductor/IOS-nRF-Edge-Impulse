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
    
    let name: String
    let id: UUID
    let advertisedID: String?
    let rssi: RSSI
    let advertisementData: AdvertisementData
    
    #if DEBUG
    init(name: String, id: UUID, rssi: RSSI, advertisementData: AdvertisementData) {
        self.name = name
        self.id = id
        self.advertisedID = advertisementData.advertisedID()
        self.rssi = rssi
        self.advertisementData = advertisementData
    }
    #endif
    
    init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        self.name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "N/A"
        let advertisementData = AdvertisementData(advertisementData)
        self.advertisementData = advertisementData
        self.rssi = RSSI(value: rssi.intValue)
        self.id = peripheral.identifier
        self.advertisedID = advertisementData.advertisedID()
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

// MARK: - Sample
#if DEBUG
extension Device {
    static let sample = Device(name: "Test Device", id: UUID(), rssi: .outOfRange, advertisementData: .mock)
}
#endif
