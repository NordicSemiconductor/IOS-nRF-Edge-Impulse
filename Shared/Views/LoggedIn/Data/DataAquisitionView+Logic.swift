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
        appData.dataAquisitionViewState.progressColor = Assets.sun.color
        appData.dataAquisitionViewState.progressString = "Requesting Sample ID..."
        
        // Note: This web Request will trigger a WebSocket Response to start Sampling.
        appData.requestNewSampleID() { response, error in
            guard response != nil else {
                let error: Error! = error
                appData.dataAquisitionViewState.samplingEncounteredAnError(error.localizedDescription)
                return
            }
        
            appData.dataAquisitionViewState.progressString = "Obtained Sample ID."
        }
    }
}
