//
//  DeploymentProgressManager.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 18/11/21.
//

import Foundation

// MARK: - DeploymentProgressManager

final class DeploymentProgressManager: ObservableObject {
    
    // MARK: Properties
    
    @Published var stages: [DeploymentStage]
    @Published var progress: Double
    
    var currentStage: DeploymentStage! {
        stages.first { $0.isInProgress }
    }
    
    // MARK: Init
    
    init() {
        self.stages = DeploymentStage.allCases
        self.progress = 0.0
        for i in stages.indices {
            stages[i].update(isInProgress: false, isCompleted: false)
            stages[i].setProgress(0)
        }
    }
}

// MARK: - Public API

internal extension DeploymentProgressManager {
    
    var isIndeterminate: Bool {
        currentStage?.isIndeterminate ?? true
    }
    
    func inProgress(_ stage: DeploymentStage) {
        guard let index = stages.firstIndex(where: { $0.toDoName == stage.id }) else { return }
        stages[index].update(isInProgress: true)
        
        for previousIndex in stages.indices where previousIndex < index {
            stages[previousIndex].update(isCompleted: true)
        }
    }
    
    func setProgress(value: Double) {
        guard value > .leastNonzeroMagnitude,
              let index = stages.firstIndex(where: { $0.isInProgress }) else { return }
        stages[index].setProgress(value)
        progress = value
    }
    
    func onError(_ error: Error) {
        guard let currentStage = stages.firstIndex(where: { $0.isInProgress }) else { return }
        stages[currentStage].declareError()
    }
    
    func success() {
        for i in stages.indices {
            stages[i].update(isCompleted: true)
            stages[i].setProgress(100)
        }
    }
}
