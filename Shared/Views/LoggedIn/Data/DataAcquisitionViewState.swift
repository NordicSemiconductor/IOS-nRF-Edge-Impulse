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
            if let maxSampleLengthS = selectedSensor.maxSampleLengthS {
                sampleLengthS = min(10, Double(maxSampleLengthS) / 2.0)
            } else {
                sampleLengthS = Constant.unselectedSampleLength
            }
        }
    }
    @Published var sampleLengthS = Constant.unselectedSampleLength
    @Published var selectedFrequency = Constant.unselectedFrequency
    @Published var progress = 0.0
    @Published var indeterminateProgress = false
    @Published var progressString = "Idle"
    @Published var progressColor = Assets.middleGrey.color
    @Published var isSampling = false
    @Published var samplingButtonEnable = true
    
    private(set) lazy var countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
    private lazy var stateCancellables = Set<AnyCancellable>()
    private lazy var timerCancellables = Set<AnyCancellable>()
    private lazy var logger = Logger(Self.self)
    
    // MARK: Init
    
    init() {
        Publishers.CombineLatest3($label.map { $0.isEmpty },
                                  $selectedDevice.map { $0 == Constant.unselectedDevice },
                                  $isSampling.map { $0 })
            .sink { emptyLabel, unselectedDevice, isSampling in
                guard !isSampling else {
                    self.samplingButtonEnable = false
                    return
                }
                self.samplingButtonEnable = !emptyLabel && !unselectedDevice
            }
            .store(in: &stateCancellables)
    }
    
    // MARK: API
    
    func newSampleMessage() -> SampleRequestMessage? {
        guard selectedSensor != Constant.unselectedSensor else { return nil }
        let intervalMs =  1.0 / selectedFrequency * 1000.0
        let message = SampleRequestMessage(category: selectedDataType, intervalMs: intervalMs, label: label,
                                           lengthMs: Int(sampleLengthS) * 1000, sensor: selectedSensor.name)
        return message
    }
    
    func newBLESampleRequest(with hmacKey: String) -> BLESampleRequestWrapper? {
        guard selectedSensor != Constant.unselectedSensor else { return nil }
        let intervalMs =  1.0 / selectedFrequency * 1000.0
        let sample = BLESampleRequest(label: label, length: Int(sampleLengthS) * 1000, hmacKey: hmacKey,
                                      category: selectedDataType, interval: intervalMs, sensor: selectedSensor)
        let message = BLESampleRequestMessage(sample: sample)
        return BLESampleRequestWrapper(scheme: .wss, host: .EdgeImpulse, message: message)
    }
    
    func samplingEncounteredAnError(_ errorDescription: String) {
        stopCountdownTimer()
        isSampling = false
        progressColor = Assets.red.color
        progressString = errorDescription
    }
}

// MARK: - Timer

extension DataAcquisitionViewState {
    
    func startCountdownTimer() {
        logger.debug(#function)
        countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
        countdownTimer.connect()
            .store(in: &timerCancellables)
    }
    
    func onSampleTimerTick(_ date: Date) {
        guard isSampling, progress < 100.0 else {
            stopCountdownTimer()
            return
        }
        
        let numberOfSeconds = Double(sampleLengthS)
        let increment = (1 / numberOfSeconds) * 100.0
        let newValue = progress + increment
        progress = min(newValue, 100.0)
    }
    
    func stopCountdownTimer() {
        logger.debug(#function)
        timerCancellables.forEach { $0.cancel() }
        timerCancellables.removeAll()
    }
}
