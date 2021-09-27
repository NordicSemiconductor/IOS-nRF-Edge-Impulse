//
//  DeploymentConfigurationView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import Foundation

extension DeploymentConfigurationView {
    
    func selectFirstAvailableDeviceHandler() {
        viewState.selectedDeviceHandler = deviceData.allConnectedAndReadyToUseDevices().first
    }
}
