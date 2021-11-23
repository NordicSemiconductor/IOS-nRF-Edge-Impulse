//
//  DeploymentConfigurationView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import Foundation
import OSLog

extension DeploymentConfigurationView {
    
    func selectFirstAvailableDeviceHandler() {
        guard let connectedDevice = deviceData.allConnectedAndReadyToUseDevices().first else {
            Logger(category: String(describing: Self.self)).debug("\(#function) no connected device found. Setting Device to Unselected.")
            viewState.selectedDevice = .Unselected
            return
        }
        viewState.selectedDeviceHandler = connectedDevice
    }
}
