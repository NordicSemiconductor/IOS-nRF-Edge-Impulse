//
//  DeploymentConfigurationView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import Foundation

extension DeploymentConfigurationView {
    
    func selectFirstAvailableDeviceHandler() {
        guard let connectedDevice = deviceData.allConnectedAndReadyToUseDevices().first else {
            viewState.selectedDevice = .Unselected
            return
        }
        viewState.selectedDeviceHandler = connectedDevice
    }
}
