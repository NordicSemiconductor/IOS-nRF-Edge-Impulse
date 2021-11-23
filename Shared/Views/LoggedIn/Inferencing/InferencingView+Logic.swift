//
//  InferencingView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import Foundation
import OSLog

extension InferencingView {
    
    // MARK: - API
    
    func selectFirstAvailableDevice() {
        guard let deviceRemoteHandler = deviceData.allConnectedOrConnectingDevices().first,
              let device = deviceRemoteHandler.device else {
                  Logger(category: String(describing: Self.self)).debug("\(#function) no connected device found. Setting Device to Unselected.")
                  appData.inferencingViewState.selectedDevice = .Unselected
                  return
              }
        appData.inferencingViewState.selectedDevice = device
    }
    
    func toggleInferencing() {
        guard let deviceRemoteHandler = deviceData.allConnectedOrConnectingDevices().first(where: { $0.device == appData.inferencingViewState.selectedDevice }) else { return }
        appData.inferencingViewState.toggleInferencing(with: deviceRemoteHandler)
    }
}
