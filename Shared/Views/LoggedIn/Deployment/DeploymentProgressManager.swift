//
//  DeploymentProgressManager.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 18/11/21.
//

import Foundation
import iOS_Common_Libraries

// MARK: - DeploymentProgressManager

final class DeploymentProgressManager: ObservableObject {
    
    // MARK: Properties
    
    @Published var stages: [DeploymentStage]
    @Published var speed: Double?
    @Published var started: Bool
    @Published var success: Bool {
        didSet {
            defer {
                delegate?.onProgressUpdate()
            }
            
            guard success else { return }
            for i in stages.indices {
                stages[i].complete()
            }
        }
    }
    
    var speedString: String? {
        guard let speed else { return nil }
        return String(format: "Speed: %.2f kB/s", speed)
    }
    
    private(set) var error: Error?
    weak var delegate: DeploymentProgressManagerDelegate?
    
    var currentStage: DeploymentStage! {
        stages.first { $0.inProgress }
    }
    
    var isIndeterminate: Bool {
        currentStage?.isIndeterminate ?? true
    }
    
    // MARK: Init
    
    init() {
        self.stages = DeploymentStage.allCases
        self.speed = nil
        self.started = false
        self.success = false
        for i in stages.indices {
            stages[i].update(inProgress: false)
        }
    }
}

// MARK: - Delegate

protocol DeploymentProgressManagerDelegate: AnyObject {
    
    func onProgressUpdate()
}

// MARK: - Public API

internal extension DeploymentProgressManager {
    
    func inProgress(_ stage: DeploymentStage, progress: Float? = nil,
                    speed: Double? = nil) {
        guard let index = stages.firstIndex(where: \.id, equals: stage.id) else { return }
        started = true
        self.speed = speed
        stages[index].update(inProgress: true, progressValue: progress)
        
        for previousIndex in stages.indices where previousIndex < index {
            stages[previousIndex].complete()
        }
        delegate?.onProgressUpdate()
    }
    
    func completed(_ stage: DeploymentStage) {
        guard let index = stages.firstIndex(where: \.id, equals: stage.id) else { return }
        stages[index].complete()
        delegate?.onProgressUpdate()
    }
    
    func onError(_ error: Error) {
        guard let currentStage = stages.firstTrueIndex(for: \.inProgress) else { return }
        self.error = error
        stages[currentStage].declareError()
        delegate?.onProgressUpdate()
    }
}
