//
//  DataAquisitionView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/6/21.
//

import Foundation

internal extension DataAcquisitionView {

    func setInitialSelectedDevice() {
        guard let device = deviceData.allConnectedAndReadyToUseDevices().first?.device else {
            return
        }
        viewState.selectedDevice = device
    }
    
    func startSampling() {
        guard let project = self.appData.selectedProject,
              let hmacKey = self.appData.projectDevelopmentKeys[project]?.hmacKey else {
            viewState.isSampling = false
            viewState.progressColor = Assets.red.color
            viewState.progressString = "Unable to find Project API Key."
            return
        }
        
        viewState.progressColor = Assets.sun.color
        viewState.progressString = "Requesting Sample ID..."
        appData.requestNewSampleID(viewState) { response, error in
            guard let response = response else {
                let error: Error! = error
                viewState.isSampling = false
                viewState.progressColor = Assets.red.color
                viewState.progressString = error.localizedDescription
                return
            }
        
            viewState.progressString = "Obtained Sample ID."
            guard let request = viewState.newBLESampleRequest(with: hmacKey) else { return }
            deviceData.startSampling(request, viewState: viewState)
        }
    }
    
    func onSampleTimerTick(_ date: Date) {
        guard viewState.isSampling, viewState.progress < 100.0 else {
            viewState.stopCountdownTimer()
            return
        }
        
        let numberOfSeconds = Double(viewState.sampleLengthInMs()) / 1000.0
        let increment = (1 / numberOfSeconds) * 100.0
        let newValue = viewState.progress + increment
        viewState.progress = min(newValue, 100.0)
    }
}
