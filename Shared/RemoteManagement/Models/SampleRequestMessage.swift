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
    let sensor: NewDataSample.Sensor
}

struct NewDataAcquisitionResponse: Codable {
    
    let success: Bool
    let id: Int
}

struct SampleRequestMessageResponse: Codable {
    
    let sample: Bool
    let error: String?
}
