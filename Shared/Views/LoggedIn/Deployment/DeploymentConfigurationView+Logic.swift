//
//  DeploymentConfigurationView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 20/7/21.
//

import Foundation

extension DeploymentConfigurationView {
    
    func selectFirstAvailableDeviceHandler() {
        viewState.selectedDeviceHandler = deviceData.allConnectedAndReadyToUseDevices().first
    }
}
