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
    @Published var started: Bool
    @Published var success: Bool {
        didSet {
            for i in stages.indices {
                stages[i].update(isCompleted: true)
            }
            progress = 100.0
        }
    }
    
    private(set) var error: Error?
    
    var currentStage: DeploymentStage! {
        stages.first { $0.isInProgress }
    }
    
    // MARK: Init
    
    init() {
        self.stages = DeploymentStage.allCases
        self.progress = 0.0
        self.started = false
        self.success = false
        for i in stages.indices {
            stages[i].update(isInProgress: false, isCompleted: false)
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
        started = true
        stages[index].update(isInProgress: true)
        
        for previousIndex in stages.indices where previousIndex < index {
            stages[previousIndex].update(isCompleted: true)
        }
    }
    
    func completed(_ stage: DeploymentStage) {
        guard let index = stages.firstIndex(where: { $0.toDoName == stage.id }) else { return }
        stages[index].update(isCompleted: true)
    }
    
    func onError(_ error: Error) {
        guard let currentStage = stages.firstIndex(where: { $0.isInProgress }) else { return }
        self.error = error
        stages[currentStage].declareError()
    }
}
