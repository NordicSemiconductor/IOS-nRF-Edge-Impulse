//
//  HelloMessage.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 08/04/2021.
//

import Foundation

struct ResponseRootObject: Codable {
    var type, direction, address: String?
    var message: Message?
}

struct Message: Codable {
    var hello: HelloMessage?
}

struct HelloMessage: Codable {
    var version: Int?
    var apiKey, deviceId, deviceType, connection: String?
    var sensors: [Sensor]?
    var supportsSnapshotStreaming: Bool?
}

struct WSHelloResponse: Codable {
    var hello: Bool
    var err: String?
}

#if DEBUG
extension ResponseRootObject {
    
    static let Thingy53v22 = ResponseRootObject(
        type: "ws",
        direction: "tx",
        address: "",
        message: Message(
            hello: HelloMessage(
                version: 3,
                apiKey: "",
                deviceId: "FF:FF:FF:FF:FF:FF",
                deviceType: "nRF5340_DK",
                connection: "ip",
                sensors: [
                    Sensor(name: "Accelerometer", maxSampleLengthS: 55866, frequencies: [62.5, 100.0]),
                    Sensor(name: "Microphone", maxSampleLengthS: 2094, frequencies: [16000.0])
                ],
                supportsSnapshotStreaming: false
            )
        )
    )
}

extension Sensor {
    static let mock = Sensor(name: "Camera", maxSampleLengthS: 1, frequencies: [1.0])
    
    static let mock1 = Sensor(name: "Camera", maxSampleLengthS: 100, frequencies: [])
    static let mock2 = Sensor(name: "Microphone", maxSampleLengthS: 60, frequencies: [16000, 8000, 11000, 32000, 44100, 48000])
    static let mock3 = Sensor(name: "Accelerometer", maxSampleLengthS: 300, frequencies: [62.5])
}

extension WSHelloResponse {
    static let success = WSHelloResponse(hello: true, err: nil)
    static let failure = WSHelloResponse(hello: false, err: "Can't establish connection")
    
    var data: Data {
        return try! JSONEncoder().encode(self)
    }
}
#endif
