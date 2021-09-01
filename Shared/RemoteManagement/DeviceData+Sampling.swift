//
//  DeviceData+Sampling.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 21/06/2021.
//

import Foundation

extension DeviceData {
    
    func startSampling(_ request: BLESampleRequestWrapper, for deviceHandler: DeviceRemoteHandler) {
        guard let samplingPublisher = deviceHandler.samplingRequestPublisher(request) else { return }
        
        dataSamplingCancellable = samplingPublisher
            .timeout(.seconds(TimeInterval(appData.dataAquisitionViewState.sampleLengthS) + TimeInterval.timeoutInterval), scheduler: DispatchQueue.main, customError: { DeviceRemoteHandler.Error.timeout })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    guard deviceHandler.samplingState != .completed else { return }
                    self.appData.dataAquisitionViewState.samplingEncounteredAnError(error.localizedDescription)
                    AppEvents.shared.error = ErrorEvent(error)
                    
                    guard let cancellable = self.dataSamplingCancellable else { return }
                    self.cancellables.remove(cancellable)
                default:
                    break
                }
            }) { [unowned self] state in
                self.appData.dataAquisitionViewState.progressString = deviceHandler.samplingState.userDescription
                switch deviceHandler.samplingState {
                case .requestReceived:
                    self.appData.dataAquisitionViewState.indeterminateProgress = true
                case .requestStarted:
                    self.appData.dataAquisitionViewState.indeterminateProgress = false
                    self.appData.dataAquisitionViewState.progress = 0.0
                    self.appData.dataAquisitionViewState.startCountdownTimer()
                case .receivingFromFirmware:
                    self.appData.dataAquisitionViewState.stopCountdownTimer()
                    self.appData.dataAquisitionViewState.progress = 100.0
                    self.appData.dataAquisitionViewState.indeterminateProgress = true
                    self.appData.dataAquisitionViewState.progressColor = Assets.blue.color
                case .completed:
                    self.appData.dataAquisitionViewState.stopCountdownTimer()
                    self.appData.dataAquisitionViewState.progress = 100.0
                    self.appData.dataAquisitionViewState.indeterminateProgress = false
                    self.appData.dataAquisitionViewState.isSampling = false
                    self.appData.dataAquisitionViewState.progressColor = .green
                    self.logger.debug("Sample Uploaded Successfully. Triggering Request for new Samples.")
                    self.appData.requestDataSamples()
                    guard let cancellable = dataSamplingCancellable else { return }
                    self.cancellables.remove(cancellable)
                default:
                    break
                }
            }
        cancellables.insert(dataSamplingCancellable)
        
        self.appData.dataAquisitionViewState.isSampling = true
        self.appData.dataAquisitionViewState.progress = 0.0
        do {
            self.appData.dataAquisitionViewState.progressString = "Sending Sample Request to Device..."
            try deviceHandler.sendSampleRequestToBLEFirmware(request)
        }
        catch (let error) {
            self.appData.dataAquisitionViewState.samplingEncounteredAnError(error.localizedDescription)
            AppEvents.shared.error = ErrorEvent(error)
        }
    }
}
