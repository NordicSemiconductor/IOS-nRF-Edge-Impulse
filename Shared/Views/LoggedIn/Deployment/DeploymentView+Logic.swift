//
//  DeploymentView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/7/21.
//

import Foundation

// MARK: - Logic

internal extension DeploymentView {
    
    func connectThenBuild() {
        viewState.$status
            .first {
                switch $0 {
                case .socketConnected, .error(_):
                    return true
                default:
                    return false
                }
            }
            .receive(on: RunLoop.main)
            .sink { status in
                switch status {
                case .socketConnected:
                    attemptToBuild()
                default:
                    break
                }
            }
            .store(in: &viewState.cancellables)
        
        attemptToConnect()
    }
    
    func retry() {
        viewState.disconnect()
        viewState.logs.removeAll()
        viewState.progress = 0.0
        viewState.status = .idle
    }
    
    func attemptToBuild() {
        guard let currentProject = appData.selectedProject,
              let apiToken = appData.apiToken else { return }
        viewState.sendBuildRequest(for: currentProject, using: apiToken)
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
