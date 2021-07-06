//
//  RegisteredDevice.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/05/2021.
//

import Foundation

struct RegisteredDevice: Codable {
    enum CodingKeys: String, CodingKey {
        case id, deviceId, created, lastSeen, deviceType, sensors, supportsSnapshotStreaming, name
        case remoteMgmtConnected = "remote_mgmt_connected"
        case remoteMgmtHost = "remote_mgmt_host"
    }
    
    var id: Int
    var deviceId: String
    var created: String // Date
    var lastSeen: String // Date
    var deviceType: String
    var sensors: [Sensor]
    var remoteMgmtConnected: Bool
    var remoteMgmtHost: String?
    var supportsSnapshotStreaming: Bool
    var name: String
}

extension RegisteredDevice: Identifiable, Hashable {
    
    static func == (lhs: RegisteredDevice, rhs: RegisteredDevice) -> Bool {
        return lhs.deviceId == rhs.deviceId && lhs.name == rhs.name
    }
}

#if DEBUG
extension RegisteredDevice {
    static let mock = RegisteredDevice(
        id: 1,
        deviceId: "ff:ff:ff:ff",
        created: "2021-01-01T00:00:00.000Z",
        lastSeen: "2021-07-04:00:00.000Z",
        deviceType: "Nordic Thingy:53",
        sensors: [ .mock1, .mock2, .mock3 ],
        remoteMgmtConnected: true,
        remoteMgmtHost: nil,
        supportsSnapshotStreaming: true,
        name: "Thingy:53"
    )
}
#endif
