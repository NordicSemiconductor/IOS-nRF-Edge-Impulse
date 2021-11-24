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
        if viewState.progressManager.success || viewState.progressManager.error != nil {
            retry()
        } else {
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
            
                  viewState.reportError(NordicError(description: "Tokens are missing."))
                  return
        }
        viewState.connect(for: currentProject, using: socketToken, and: apiToken)
    }
    
    func retry() {
        viewState.disconnect()
        viewState.logs.removeAll()
        viewState.progressManager = DeploymentProgressManager()
        viewState.progressManager.delegate = viewState
        viewState.status = .idle
    }
}
