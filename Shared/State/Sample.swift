//
//  Sample.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import Foundation

// MARK: - Sample

struct Sample {
    
    let label: String
    let sensor: Sensor
    let frequency: Frequency
}

// MARK: - Sensor

enum Sensor: String, RawRepresentable, CaseIterable {
    case Accelerometer
    case Microphone
    case Camera
}

// MARK: - Frequency

enum Frequency: Int, RawRepresentable, CaseIterable, CustomStringConvertible {
    case _8000Hz = 8000
    case _11000Hz = 11000
    case _16000Hz = 16000
    case _32000Hz = 32000
    case _44100Hz = 44100
    case _48000Hz = 48000
    
    var description: String {
        "\(rawValue) Hz"
    }
}
