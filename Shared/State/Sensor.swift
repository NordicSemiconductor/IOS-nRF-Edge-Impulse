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
    
    var sampleLengthUnit: String {
        isMicrophone ? "s" : "ms"
    }
    
    var sampleLengthString: String {
        guard let maxSampleLengthS = maxSampleLengthS else { return "N/A" }
        return "\(maxSampleLengthS) \(sampleLengthUnit)"
    }
}

// MARK: - isMicrophone()

extension Sensor {
    
    var isMicrophone: Bool { name.caseInsensitiveCompare("Microphone") == .orderedSame }
}

// MARK: - Identifiable, Hashable

extension Sensor: Identifiable, Hashable {
    
    var id: String { name }
}
