//
//  DataAcquisitionViewState.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 19/3/21.
//

import Foundation
import OSLog
import Combine

final class DataAcquisitionViewState: ObservableObject {
    
    // MARK: Properties
    
    @Published var label = ""
    @Published var selectedDevice = Constant.unselectedDevice {
        didSet {
            guard selectedDevice != Constant.unselectedDevice else { return }
            selectedSensor = selectedDevice.sensors.first ?? Constant.unselectedSensor
        }
    }
    @Published var selectedDataType = DataSample.Category.training
    @Published var selectedSensor = Constant.unselectedSensor {
        didSet {
            guard selectedSensor != Constant.unselectedSensor else { return }
            selectedFrequency = selectedSensor.frequencies?.first ?? Constant.unselectedFrequency
            sampleLength = Constant.unselectedSampleLength
        }
    }
    @Published var sampleLength = Constant.unselectedSampleLength
    @Published var selectedFrequency = Constant.unselectedFrequency
    @Published var progress = 0.0
    @Published var progressString = ""
    @Published var isSampling = false
    
    private(set) lazy var countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
    private lazy var cancellables = Set<AnyCancellable>()
    private lazy var logger = Logger(Self.self)
    
    var canStartSampling: Bool {
        selectedDevice != Constant.unselectedDevice && label.hasItems
    }
    
    // MARK: API
    
    func newSampleMessage() -> SampleRequestMessage? {
        guard selectedSensor != Constant.unselectedSensor else { return nil }
        let intervalMs =  1.0 / selectedFrequency * 1000.0
        let message = SampleRequestMessage(category: selectedDataType, intervalMs: intervalMs, label: label,
                                           lengthMs: Int(sampleLength), sensor: selectedSensor.name)
        return message
    }
    
    func newBLESampleRequest(with hmacKey: String) -> BLESampleRequestWrapper? {
        guard selectedSensor != Constant.unselectedSensor else { return nil }
        let intervalMs =  1.0 / selectedFrequency * 1000.0
        let sample = BLESampleRequest(label: label, length: Int(sampleLength), hmacKey: hmacKey, category: selectedDataType,
                                      interval: Int(intervalMs), sensor: selectedSensor)
        let message = BLESampleRequestMessage(sample: sample)
        return BLESampleRequestWrapper(scheme: .wss, host: .EdgeImpulse, message: message)
    }
    
    func startCountdownTimer() {
        logger.debug(#function)
        countdownTimer.connect()
            .store(in: &cancellables)
    }
    
    func stopCountdownTimer() {
        logger.debug(#function)
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
