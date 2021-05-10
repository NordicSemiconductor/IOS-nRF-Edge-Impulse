//
//  SampleRequestMessage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 10/5/21.
//

import Foundation

struct SampleRequestMessage: Codable {
    
    let label: String
    let length: Int
    let interval: Int
    let sensor: String
}

struct SampleRequestMessageContainer: Codable {
    
    let sample: SampleRequestMessage
}

struct SampleRequestMessageResponse: Codable {
    
    let sample: Bool
    let error: String?
}
