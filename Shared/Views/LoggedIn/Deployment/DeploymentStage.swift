//
//  DeploymentStage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 10/11/21.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - DeploymentStage

struct DeploymentStage: PipelineStage {
    
    let id: String
    let todoStatus: String
    let inProgressStatus: String
    let completedStatus: String
    let symbolName: String
    let isIndeterminate: Bool
    
    var progress: Float
    var totalProgress: Float
    var inProgress: Bool
    var encounteredAnError: Bool
    var completed: Bool
    
    // MARK: Init
    
    private init(todoStatus: String, inProgressStatus: String, completedStatus: String,
                 symbolName: String, isIndeterminate: Bool) {
        self.id = todoStatus
        self.todoStatus = todoStatus
        self.inProgressStatus = inProgressStatus
        self.completedStatus = completedStatus
        self.symbolName = symbolName
        self.isIndeterminate = isIndeterminate
        self.progress = .zero
        self.totalProgress = 100.0
        self.inProgress = false
        self.encounteredAnError = false
        self.completed = false
    }
}

// MARK: - CaseIterable

extension DeploymentStage: CaseIterable {
    
    // MARK: Cases
    
    static let online = DeploymentStage(todoStatus: "Connect to Server", inProgressStatus: "Connecting to Server...", completedStatus: "Connected to Edge Impulse", symbolName: "network", isIndeterminate: true)
    
    static let building = DeploymentStage(todoStatus: "Build", inProgressStatus: "Building...", completedStatus: "Built", symbolName: "hammer", isIndeterminate: true)

    static let downloading = DeploymentStage(todoStatus: "Download", inProgressStatus: "Downloading...", completedStatus: "Downloaded", symbolName: "square.and.arrow.down", isIndeterminate: false)
    
    static let verifying = DeploymentStage(todoStatus: "Verify", inProgressStatus: "Verifying...", completedStatus: "Verified", symbolName: "list.bullet", isIndeterminate: true)
    
    static let uploading = DeploymentStage(todoStatus: "Upload", inProgressStatus: "Uploading...", completedStatus: "Uploaded", symbolName: "square.and.arrow.up", isIndeterminate: false)
    
    static let confirming = DeploymentStage(todoStatus: "Confirm", inProgressStatus: "Confirming...", completedStatus: "Confirmed", symbolName: "checkerboard.shield", isIndeterminate: true)
    
    static let applying = DeploymentStage(todoStatus: "Update", inProgressStatus: "Applying Update...", completedStatus: "Updated", symbolName: "rectangle.2.swap", isIndeterminate: false)
    
    static let completed = DeploymentStage(todoStatus: "Complete", inProgressStatus: "Completing...", completedStatus: "Completed", symbolName: "checkmark", isIndeterminate: true)
    
    // MARK: CaseIterable
    
    static var allCases: [DeploymentStage] = [.online, .building, .downloading, .verifying, .uploading, .confirming, .applying, .completed]
}
