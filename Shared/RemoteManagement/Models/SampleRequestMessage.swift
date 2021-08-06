//
//  SampleRequestMessage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 10/5/21.
//

import Foundation

struct SampleRequestMessage: Codable {
    
    let category: DataSample.Category
    let intervalMs: Double
    let label: String
    let lengthMs: Int
    let sensor: String
    
    var intervalS: Double {
        ceil(Double(lengthMs) / 1000.0)
    }
}

struct BLESampleRequest: Codable {
    
    let label: String
    let length: Int
    let path: String
    let hmacKey: String
    let interval: Double
    let sensor: String
    
    init(label: String, length: Int, hmacKey: String, category: DataSample.Category, interval: Double, sensor: Sensor) {
        self.label = label
        self.length = length
        self.path = "/api/\(category.rawValue)/data"
        self.hmacKey = hmacKey
        self.interval = interval
        self.sensor = sensor.name
    }
}

// MARK: - BLE Hello Message

struct BLEHelloMessage: Codable {
    let hello: Bool
}

struct BLEHelloMessageContainer: Codable {
    
    let type: String
    let direction: String
    let address: String
    let message: BLEHelloMessage
    
    init(message: BLEHelloMessage) {
        self.type = "ws"
        self.direction = "rx"
        self.address = HTTPScheme.wss.rawValue + "://" + HTTPHost.EdgeImpulse.rawValue
        self.message = message
    }
}

// MARK: - BLE Configure Message

struct BLEConfigureMessage: Codable {
    
    let apiKey: String
    let address: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
        self.address = HTTPScheme.wss.rawValue + "://" + HTTPHost.EdgeImpulse.rawValue
    }
}

struct BLEConfigureMessageContainer: Codable {
    
    let type: String
    let message: BLEConfigureMessage
    
    init(message: BLEConfigureMessage) {
        self.type = "configure"
        self.message = message
    }
}

// MARK: - BLE Sample Request Message

struct BLESampleRequestMessage: Codable {
    
    let sample: BLESampleRequest
}

struct BLESampleRequestWrapper: Codable {
    
    let type: String
    let direction: String
    let address: String
    let message: BLESampleRequestMessage
    
    init(scheme: HTTPScheme, host: HTTPHost, message: BLESampleRequestMessage) {
        self.type = "ws"
        self.direction = "rx"
        self.address = scheme.rawValue + "://" + host.rawValue
        self.message = message
    }
}

struct SamplingRequestReceivedResponse: Codable {
    
    let type: String
    let direction: String
    let address: String
    let message: SamplingRequestReceivedResponseMessage
}

struct SamplingRequestReceivedResponseMessage: Codable {
    let sample: Bool
}

struct SamplingRequestStartedResponse: Codable {
    
    let type: String
    let direction: String
    let address: String
    let message: SamplingRequestStartedResponseMssage
}

struct SamplingRequestStartedResponseMssage: Codable {
    
    let sampleStarted: Bool
}

struct SamplingRequestUploadingResponse: Codable {
    
    let type: String
    let direction: String
    let address: String
    let message: SamplingRequestUploadingResponseMssage
}

struct SamplingRequestUploadingResponseMssage: Codable {
    
    let sampleUploading: Bool
}

struct SamplingRequestFinishedResponse: Codable {
 
    struct Headers: Codable {
        let apiKey: String
        let label: String
        let allowDuplicates: String
        
        enum CodingKeys: String, CodingKey {
            case apiKey = "api-key"
            case label
            case allowDuplicates = "allow-duplicates"
        }
    }
    
    let type: String
    let address: String
    let method: String
    let headers: Headers
    let body: String
}

struct DataAcquisitionSample: Codable {
    
    let id: Int
    let filename: String
    let signatureValidate: Bool
    let signatureMethod: String
    let signatureKey: String
    let category: DataSample.Category
    let coldstorageFilename: String
    let label: String
    let intervalMs: Double
    let frequency: Double?
    let deviceName: String
    let deviceType: String
    let sensors: [Sensor]
    let valuesCount: Int
    let totalLengthMs: Int
}

// MARK: - DataAcquisitionSample.Sensor

extension DataAcquisitionSample {
    
    struct Sensor: Codable {
        let name: String
        let units: String
    }
}

struct DataAcquisitionPayload: Codable {
    
    let device_name: String
    let device_type: String
    let interval_ms: Double
    let frequency: Double?
    let values: [[Double]]
    let sensors: [DataAcquisitionSample.Sensor]
}

struct FullDataAcquisitionData: Codable {
    
    let success: Bool
    let sample: DataAcquisitionSample
    let payload: DataAcquisitionPayload
    let totalPayloadLength: Int
}
