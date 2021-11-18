//
//  DeploymentViewState+DeploymentStage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 18/11/21.
//

import Foundation

// MARK: - StageManagement

internal extension DeploymentViewState {
    
    func setAllStagesToIdle() {
        for i in stages.indices {
            stages[i].update(isInProgress: false, isCompleted: false)
            stages[i].setProgress(0)
        }
    }
    
    func setStageToInProgress(_ stage: DeploymentStage) {
        guard let index = stages.firstIndex(where: { $0.toDoName == stage.id }) else { return }
        stages[index].update(isInProgress: true)
        
        for previousIndex in stages.indices where previousIndex < index {
            stages[previousIndex].update(isCompleted: true)
        }
    }
    
    func setAllStagesToSuccess() {
        for i in stages.indices {
            stages[i].update(isCompleted: true)
            stages[i].setProgress(100)
        }
    }
}
