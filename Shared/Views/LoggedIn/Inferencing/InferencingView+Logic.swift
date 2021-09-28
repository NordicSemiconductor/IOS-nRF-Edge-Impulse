//
//  InferencingView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import Foundation

extension InferencingView {
    
    // MARK: - API
    
    func selectFirstAvailableDeviceHandler() {
        appData.inferencingViewState.selectedDeviceHandler = deviceData.allConnectedAndReadyToUseDevices().first
    }
}
