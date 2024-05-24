//
//  DeploymentView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/7/21.
//

import Foundation
import iOS_Common_Libraries

// MARK: - Logic

internal extension DeploymentView {
    
    func buttonAction() {
        if viewState.pipelineManager.success || viewState.pipelineManager.error != nil {
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
              let projectApiKey = appData.projectDevelopmentKeys[currentProject]?.apiKey else {
            
                  viewState.reportError(NordicError(description: "Tokens are missing."))
                  return
        }
        viewState.speed = nil
        viewState.buildButtonEnable = false
        viewState.connect(for: currentProject, using: socketToken, and: projectApiKey)
    }
    
    func retry() {
        viewState.disconnect()
        viewState.logs.removeAll()
        viewState.pipelineManager = PipelineManager(initialStages: DeploymentStage.allCases)
        viewState.speed = nil
        viewState.selectedDeviceHandler = nil
        viewState.buildButtonEnable = false
        viewState.buildButtonText = "Build"
    }
}
