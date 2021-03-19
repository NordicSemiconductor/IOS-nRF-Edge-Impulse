//
//  DataAcquisitionViewState.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 19/3/21.
//

import Combine

final class DataAcquisitionViewState: ObservableObject {
    
    @Published var selectedProject: Project?
    @Published var label = ""
    @Published var selectedDevice: Device?
    @Published var selectedDataType = Sample.DataType.Test
    @Published var selectedSensor = Sample.Sensor.Accelerometer
    @Published var sampleLength = 10000.0
    @Published var selectedFrequency = Sample.Frequency._11000Hz
    
    var canSelectSampleLengthAndFrequency: Bool {
        selectedSensor != .Camera
    }
    
    var canStartSampling: Bool {
        selectedProject != nil || selectedDevice != nil || label.count < 1
    }
}
