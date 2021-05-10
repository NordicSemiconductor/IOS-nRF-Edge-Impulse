//
//  DataAcquisitionViewState.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 19/3/21.
//

import Foundation
import Combine

final class DataAcquisitionViewState: ObservableObject {
    
    @Published var label = ""
    @Published var selectedDevice = Constant.unselectedDevice
    @Published var selectedDataType = DataSample.Category.training
    @Published var selectedSensor = NewDataSample.Sensor.Accelerometer
    @Published var sampleLength = 10000.0
    @Published var selectedFrequency = NewDataSample.Frequency._11000Hz
    
    var canSelectSampleLengthAndFrequency: Bool {
        selectedSensor != .Camera
    }
    
    var canStartSampling: Bool {
        selectedDevice != Constant.unselectedDevice && label.hasItems
    }
    
    func newSampleMessage() -> SampleRequestMessageContainer {
        let message = SampleRequestMessage(label: label, length: Int(sampleLength), interval: selectedFrequency.rawValue, sensor: selectedSensor.rawValue)
        let container = SampleRequestMessageContainer(sample: message)
        return container
    }
}
