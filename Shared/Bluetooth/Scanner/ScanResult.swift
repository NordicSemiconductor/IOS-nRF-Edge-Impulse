//
//  ScanResult.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import Foundation
import CoreBluetooth.CBPeripheral

// MARK: - RSSI

struct RSSI: ExpressibleByIntegerLiteral, Equatable, Hashable {
    init(integerLiteral value: Int) {
        self.value = value
        self.condition = Condition(value: value)
    }
    
    typealias IntegerLiteralType = Int
    
    enum Condition: Int {
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
    
    let value: Int
    let condition: Condition
    
    
}

// MARK: - ScanResult

/// `ScanResult` represents discovered device by Scanner
struct ScanResult: Identifiable {
    
    let name: String
    let id: String
    let uuid: UUID
    let rssi: RSSI
    let advertisementData: AdvertisementData
    let isConnectable: Bool
    
    init(name: String, uuid: UUID, rssi: RSSI, advertisementData: AdvertisementData) {
        self.name = name
        self.id = advertisementData.advertisedID() ?? uuid.uuidString
        self.uuid = uuid
        self.rssi = rssi
        self.advertisementData = advertisementData
        self.isConnectable = advertisementData.isConnectable ?? false
    }
    
    init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        self.name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "N/A"
        let advertisementData = AdvertisementData(advertisementData)
        self.advertisementData = advertisementData
        self.rssi = RSSI(integerLiteral: rssi.intValue)
        self.id = advertisementData.advertisedID() ?? peripheral.identifier.uuidString
        self.uuid = peripheral.identifier
        self.isConnectable = advertisementData.isConnectable ?? false
    }
    
    static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
        return lhs.id == rhs.id && lhs.isConnectable == rhs.isConnectable
    }
}

// MARK: - DeviceScanResult

extension ScanResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isConnectable)
    }
}

// MARK: - Sample

extension RSSI {
    static let outOfRange: RSSI = 127
    static let practicalWorst: RSSI = -100
    static let bad: RSSI = -90
    static let ok: RSSI = -80
    static let good: RSSI = -50
}

#if DEBUG
extension ScanResult {
    static let sample = ScanResult(name: "Test Device", uuid: UUID(), rssi: .outOfRange, advertisementData: .connectableMock)
    static let unconnectableSample = ScanResult(name: "2021 Belgian NoPrix", uuid: UUID(), rssi: .outOfRange, advertisementData: .unconnectableMock)
}
#endif
