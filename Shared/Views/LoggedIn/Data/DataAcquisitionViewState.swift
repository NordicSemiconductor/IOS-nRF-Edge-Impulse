//
//  DataAcquisitionViewState.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 19/3/21.
//

import Foundation
import Combine

final class DataAcquisitionViewState: ObservableObject {
    
    @Published var selectedProject = Constant.unselectedProject
    @Published var label = ""
    @Published var selectedDevice = Constant.unselectedDevice
    @Published var selectedDataType = NewDataSample.DataType.Test
    @Published var selectedSensor = NewDataSample.Sensor.Accelerometer
    @Published var sampleLength = 10000.0
    @Published var selectedFrequency = NewDataSample.Frequency._11000Hz
    
    var canSelectSampleLengthAndFrequency: Bool {
        selectedSensor != .Camera
    }
    
    var canStartSampling: Bool {
        selectedProject != Constant.unselectedProject && selectedDevice != Constant.unselectedDevice && label.count > 0
    }
}
