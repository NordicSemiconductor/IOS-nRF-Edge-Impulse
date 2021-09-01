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
        appData.dataAquisitionViewState.selectedDevice = device
    }
    
    func startSampling() {
        guard let project = self.appData.selectedProject,
              let hmacKey = self.appData.projectDevelopmentKeys[project]?.hmacKey else {
            appData.dataAquisitionViewState.isSampling = false
            appData.dataAquisitionViewState.progressColor = Assets.red.color
            appData.dataAquisitionViewState.progressString = "Unable to find Project API Key."
            return
        }
        
        appData.dataAquisitionViewState.progressColor = Assets.sun.color
        appData.dataAquisitionViewState.progressString = "Requesting Sample ID..."
        appData.requestNewSampleID() { response, error in
            guard let response = response else {
                let error: Error! = error
                appData.dataAquisitionViewState.isSampling = false
                appData.dataAquisitionViewState.progressColor = Assets.red.color
                appData.dataAquisitionViewState.progressString = error.localizedDescription
                return
            }
        
            appData.dataAquisitionViewState.progressString = "Obtained Sample ID."
            guard let request = appData.dataAquisitionViewState.newBLESampleRequest(with: hmacKey),
                  let deviceHandler = deviceData[appData.dataAquisitionViewState.selectedDevice] else { return }
            deviceData.startSampling(request, for: deviceHandler)
        }
    }
    
    func onSampleTimerTick(_ date: Date) {
        guard appData.dataAquisitionViewState.isSampling, appData.dataAquisitionViewState.progress < 100.0 else {
            appData.dataAquisitionViewState.stopCountdownTimer()
            return
        }
        
        let numberOfSeconds = Double(appData.dataAquisitionViewState.sampleLengthS)
        let increment = (1 / numberOfSeconds) * 100.0
        let newValue = appData.dataAquisitionViewState.progress + increment
        appData.dataAquisitionViewState.progress = min(newValue, 100.0)
    }
}
