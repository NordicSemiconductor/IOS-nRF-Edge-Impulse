//
//  HelloMessage.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 08/04/2021.
//

import Foundation

struct ResponseRootObject: Codable {
    let hello: HelloMessage
}

struct HelloMessage: Codable {
    let version: Int
    let apiKey, deviceID, deviceType, connection: String
    let sensors: [Sensor]
    let supportsSnapshotStreaming: Bool

    enum CodingKeys: String, CodingKey {
        case version, apiKey
        case deviceID = "deviceId"
        case deviceType, connection, sensors, supportsSnapshotStreaming
    }
}

struct Sensor: Codable {
    let name: String
    let maxSampleLengthS: Int
    // TODO: Figure out what the `frequencies` field contains
//    let frequencies: [Any]
}
