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

struct WSHelloResponse: Codable {
    let hello: Bool
    let err: String?
}

#if DEBUG
extension ResponseRootObject {
    static let mock = ResponseRootObject(
        hello: HelloMessage(
            version: 1,
            apiKey: "ei_8dd502530a5232ff64374815fddc229151e0a82c1d4f23e86097d8acdf882295",
            deviceID: "15:FE:90:11:1D:18",
            deviceType: "PORTENTA_H7_M7",
            connection: "daemon",
            sensors: [Sensor(name: "Camera (320x240)", maxSampleLengthS: 60000)],
            supportsSnapshotStreaming: true
        )
    )
}

extension WSHelloResponse {
    static let success = WSHelloResponse(hello: true, err: nil)
    static let failure = WSHelloResponse(hello: false, err: "Can't establish connection")
    
    var data: Data {
        return try! JSONEncoder().encode(self)
    }
}
#endif
