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

struct Sensor: Codable {
    var name: String
    var maxSampleLengthS: Int?
    var frequencies: [Double]?
}

extension Sensor: Identifiable, Hashable {
    var id: String { name }
}

struct WSHelloResponse: Codable {
    var hello: Bool
    var err: String?
}

#if DEBUG
extension ResponseRootObject {
    static let moc = ResponseRootObject(
        type: "",

        direction: "",
        address: "",
        message: Message(
            hello: HelloMessage(
                version: 1,
                apiKey: "ei_8dd502530a5232ff64374815fddc229151e0a82c1d4f23e86097d8acdf882295",
                deviceId: "15:FE:90:11:1D:18",
                deviceType: "PORTENTA_H7_M7",
                connection: "daemon",
                sensors: [
                    Sensor(name: "Camera (320x240)", maxSampleLengthS: 1, frequencies: [1.0])
                ],
                supportsSnapshotStreaming: true
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
