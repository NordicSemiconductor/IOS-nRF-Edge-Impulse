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
              let requestPublisher = deviceHandler?.samplingRequestPublisher() else { return }
        
        requestPublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    viewState.stopCountdownTimer()
                    viewState.isSampling = false
                    AppEvents.shared.error = ErrorEvent(error)
                default:
                    break
                }
            }) { state in
                switch state {
                case .requestReceived:
                    viewState.progressString = "Request Received"
                case .requestStarted:
                    viewState.progressString = "Sampling Started"
                    viewState.startCountdownTimer()
                case .completed:
                    viewState.progressString = "Finished successfully"
                default:
                    print(String(describing: state))
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
