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

struct SamplingRequestReceivedResponse: Codable {
    
    let sample: Bool
}

struct SamplingRequestStartedResponse: Codable {
    
    let sampleStarted: Bool
}

struct SamplingRequestProcessingResponse: Codable {
    
    let sampleProcessing: Bool
}

struct SamplingRequestProgressResponse: Codable {
    
    let sampleReading: Bool
    let progressPercentage: Int
}

struct SamplingRequestUploadingResponse: Codable {
    
    let sampleUploading: Bool
}

struct SamplingRequestFinishedResponse: Codable {
    
    let sampleFinished: Bool
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
