//
//  Sensor.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 30/8/21.
//

import Foundation

// MARK: - Sensor

struct Sensor: Codable {
    
    let name: String
    let maxSampleLengthS: Int?
    let frequencies: [Double]?
}

// MARK: - Identifiable, Hashable

extension Sensor: Identifiable, Hashable {
    
    var id: String { name }
}
