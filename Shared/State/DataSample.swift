//
//  DataSample.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/5/21.
//

import Foundation

struct DataSample: Identifiable, Codable {
    
    let id: Int
    let filename: String
    let category: Category
    let label: String
    let intervalMs: Double?
    let frequency: Double?
    let totalLengthMs: Double
    let sensors: [DataSample.Sensor]
    
    var symbolName: String {
        switch sensors.first?.units.trimmingCharacters(in: .whitespacesAndNewlines) {
        case "m/s2":
            return "gyroscope"
        case "wav":
            return "mic"
        case "Gaus":
            return "tuningfork"
        case "lux":
            return "lightbulb"
        case "degC":
            return "wind"
        default:
            return "square"
        }
    }
    
    func totalLengthInSeconds() -> String {
        let double = Measurement(value: totalLengthMs, unit: UnitDuration.milliseconds)
            .converted(to: .seconds).value
        return String(format: "%.2fs", double)
    }
}

// MARK: - DataSample.Category

extension DataSample {
    
    enum Category: String, Identifiable, Codable, RawRepresentable, CaseIterable {
        case training, testing
        
        var id: Int {
            rawValue.hashValue
        }
    }
}

// MARK: - DataSample.Sensor

extension DataSample {
    
    struct Sensor: Codable {
        
        let name: String
        let units: String
    }
}
