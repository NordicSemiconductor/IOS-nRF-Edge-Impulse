//
//  NewDataSample.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import Foundation

// MARK: - NewDataSample

struct NewDataSample {
    
    let label: String
    let sensor: Sensor
    let frequency: Frequency
}

// MARK: - NewDataSample.DataType

extension NewDataSample {
    
    enum DataType: String, RawRepresentable, Identifiable, CaseIterable {
        case Test
        case Training
        
        var id: Int {
            rawValue.hashValue
        }
        
        var description: String {
            switch self {
            case .Test:
                return "Test Data"
            case .Training:
                return "Training Data"
            }
        }
    }
}
    
// MARK: - NewDataSample.Sensor

extension NewDataSample {
    
    enum Sensor: String, RawRepresentable, Identifiable, CaseIterable {
        case Accelerometer
        case Microphone
        case Camera
        
        var id: Int {
            rawValue.hash
        }
    }
}

// MARK: - NewDataSample.Frequency

extension NewDataSample {

    enum Frequency: Int, RawRepresentable, Identifiable, CaseIterable, CustomStringConvertible {
        case _8000Hz = 8000
        case _11000Hz = 11000
        case _16000Hz = 16000
        case _32000Hz = 32000
        case _44100Hz = 44100
        case _48000Hz = 48000
        
        var id: Int {
            rawValue
        }
        
        var description: String {
            "\(rawValue) Hz"
        }
    }
}
