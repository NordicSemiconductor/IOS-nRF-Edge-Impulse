//
//  DeviceData+Sampling.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 21/06/2021.
//

import Foundation

extension DeviceData {
    func startSampling(_ viewState: DataAcquisitionViewState) {
        let deviceHandler = self[viewState.selectedDevice]
        guard let project = self.appData.selectedProject,
              let hmacKey = self.appData.projectDevelopmentKeys[project]?.hmacKey,
              let newSampleMessage = viewState.newBLESampleRequest(with: hmacKey),
              let samplingPublisher = deviceHandler?.samplingRequestPublisher(sampleState: viewState) else { return }
        
        samplingPublisher
            .timeout(.seconds(.timeoutInterval), scheduler: DispatchQueue.main, customError: { DeviceRemoteHandler.Error.timeout })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    guard deviceHandler?.samplingState != .completed else { return }
                    viewState.stopCountdownTimer()
                    viewState.isSampling = false
                    viewState.progressString = error.localizedDescription
                    AppEvents.shared.error = ErrorEvent(error)
                default:
                    break
                }
            }) { state in
                viewState.progressString = deviceHandler?.samplingState.userDescription ?? ""
                switch deviceHandler?.samplingState {
                case .requestStarted:
                    viewState.startCountdownTimer()
                case .receivingFromFirmware:
                    viewState.stopCountdownTimer()
                    viewState.progress = 100.0
                case .completed:
                    viewState.stopCountdownTimer()
                    viewState.progress = 100.0
                    viewState.isSampling = false
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewState.isSampling = true
        do {
            viewState.progressString = "Sending Sample Request to Firmware..."
            try deviceHandler?.sendSampleRequestToBLEFirmware(newSampleMessage)
        }
        catch (let error) {
            viewState.isSampling = false
            AppEvents.shared.error = ErrorEvent(error)
        }
    }
}
