//
//  DeploymentView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/7/21.
//

import Foundation

// MARK: - Logic

internal extension DeploymentView {
    
    func buttonAction() {
        switch viewState.status {
        case .success, .error(_):
            retry()
        default:
            start()
        }
    }
}

// MARK: - Private

fileprivate extension DeploymentView {
    
    func start() {
        guard viewState.selectedDeviceHandler != nil,
              let currentProject = appData.selectedProject,
              let socketToken = appData.projectSocketTokens[currentProject],
              let apiToken = appData.apiToken else {
            
                  viewState.status = .error(NordicError(description: "Tokens are missing."))
                  viewState.progressManager.onError(NordicError(description: "Tokens are missing."))
                  return
        }
        viewState.connect(for: currentProject, using: socketToken, and: apiToken)
    }
    
    func retry() {
        viewState.disconnect()
        viewState.logs.removeAll()
        viewState.progressManager = DeploymentProgressManager()
        viewState.status = .idle
    }
}
