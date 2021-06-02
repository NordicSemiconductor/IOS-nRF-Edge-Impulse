//
//  DataAcquisitionViewState.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 19/3/21.
//

import Foundation
import Combine

final class DataAcquisitionViewState: ObservableObject {
    
    // MARK: Properties
    
    @Published var label = ""
    @Published var selectedDevice = Constant.unselectedDevice
    @Published var selectedDataType = DataSample.Category.training
    @Published var selectedSensor = NewDataSample.Sensor.Accelerometer
    @Published var sampleLength = 10000.0
    @Published var selectedFrequency = NewDataSample.Frequency._11000Hz
    @Published var progress = 0.0
    @Published var isSampling = false {
        didSet {
            if isSampling {
                countdownTimer.connect()
                    .store(in: &cancellables)
            } else {
                cancellables.forEach { $0.cancel() }
                cancellables.removeAll()
            }
        }
    }
    
    private(set) lazy var countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
    private lazy var cancellables = Set<AnyCancellable>()
    
    var canSelectSampleLengthAndFrequency: Bool {
        selectedSensor != .Camera
    }
    
    var canStartSampling: Bool {
        selectedDevice != Constant.unselectedDevice && label.hasItems
    }
    
    // MARK: API
    
    func newSampleMessage() -> SampleRequestMessage {
        let interval = sampleLength / Double(selectedFrequency.rawValue)
        let message = SampleRequestMessage(category: selectedDataType, intervalMs: interval, label: label, lengthMs: Int(sampleLength), sensor: selectedSensor)
        return message
    }
}
