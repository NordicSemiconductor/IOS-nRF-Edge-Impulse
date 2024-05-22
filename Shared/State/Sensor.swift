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
    
    var iconName: String {
        guard !name.contains("+") else { return "slider.vertical.3" }
        switch name {
        case "Camera":
            return "camera"
        case "Microphone":
            return "mic"
        case "Accelerometer":
            return "gyroscope"
        case "Magnetometer":
            return "tuningfork"
        case "Light":
            return "lightbulb"
        case "Inertial":
            return "cursorarrow.motionlines"
        case "Interaction":
            return "hand.point.up"
        case "Environment":
            return "wind"
        default:
            return "square"
        }
    }
}

// MARK: - CustomStringConvertible

extension Sensor: CustomStringConvertible {
    
    var description: String { name }
}

// MARK: - Identifiable, Hashable

extension Sensor: Identifiable, Hashable {
    
    var id: String { name }
}
