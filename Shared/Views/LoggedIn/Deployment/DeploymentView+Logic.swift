//
//  DeploymentView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/7/21.
//

import Foundation

// MARK: - Logic

internal extension DeploymentView {
    
    func attemptToBuild() {
        guard let currentProject = appData.selectedProject,
              let apiToken = appData.apiToken else { return }
        viewState.sendBuildRequest(for: currentProject, using: apiToken)
    }
    
    func retry() {
        viewState.status = .idle
        attemptToConnect()
    }
    
    func attemptToConnect() {
        guard viewState.isReadyToConnect,
              let currentProject = appData.selectedProject,
              let socketToken = appData.projectSocketTokens[currentProject] else {
            viewState.status = .error(NordicError(description: "Tokens are missing."))
            return
        }
        viewState.connect(using: socketToken)
    }
}
