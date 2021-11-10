//
//  DeploymentStage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 10/11/21.
//

import SwiftUI

// MARK: - DeploymentStage

struct DeploymentStage: Identifiable {
    
    let id: String
    let toDoName: String
    let inProgressName: String
    let finishedName: String
    let symbolName: String
    
    var isInProgress: Bool
    var encounteredAnError: Bool
    var isCompleted: Bool
    
    // MARK: Init
    
    private init(toDoName: String, inProgressName: String, finishedName: String,
                 symbolName: String, inProgressStatus: DeploymentViewState.JobStatus,
                 completedStatuses: [DeploymentViewState.JobStatus]) {
        self.id = toDoName
        self.toDoName = toDoName
        self.inProgressName = inProgressName
        self.finishedName = finishedName
        self.symbolName = symbolName
        self.isInProgress = false
        self.encounteredAnError = false
        self.isCompleted = false
    }
    
    // MARK: API
    
    var name: String {
        guard !isCompleted else { return finishedName }
        return isInProgress || encounteredAnError ? inProgressName : toDoName
    }
    
    var color: Color {
        if isCompleted {
            return .succcessfulActionButtonColor
        } else if encounteredAnError {
            return Assets.red.color
        } else if isInProgress {
            return Assets.sun.color
        }
        return .disabledTextColor
    }
    
    mutating func update(isInProgress: Bool = false, isCompleted: Bool = false) {
        self.encounteredAnError = false
        self.isInProgress = isInProgress
        self.isCompleted = isCompleted
    }
    
    mutating func declareError() {
        guard isInProgress else { return }
        isInProgress = false
        encounteredAnError = true
    }
}

// MARK: - CaseIterable

extension DeploymentStage: CaseIterable {
    
    // MARK: Cases
    
    static let building = DeploymentStage(toDoName: "Build", inProgressName: "Building...", finishedName: "Built", symbolName: "hammer", inProgressStatus: .buildingModel(5), completedStatuses: [.downloadingModel, .unpackingModelData, .uploading(1), .applying, .confirming, .success])

    static let downloading = DeploymentStage(toDoName: "Download", inProgressName: "Downloading...", finishedName: "Downloaded", symbolName: "square.and.arrow.down", inProgressStatus: .downloadingModel, completedStatuses: [.unpackingModelData, .uploading(1), .applying, .confirming, .success])
    
    static let verifying = DeploymentStage(toDoName: "Verify", inProgressName: "Verifying...", finishedName: "Verified", symbolName: "list.bullet", inProgressStatus: .unpackingModelData, completedStatuses: [.uploading(1), .applying, .confirming, .success])
    
    static let uploading = DeploymentStage(toDoName: "Upload", inProgressName: "Uploading...", finishedName: "Uploaded", symbolName: "square.and.arrow.up", inProgressStatus: .uploading(5), completedStatuses: [.success])
    
    static let confirming = DeploymentStage(toDoName: "Confirm", inProgressName: "Confirming...", finishedName: "Confirmed", symbolName: "metronome", inProgressStatus: .confirming, completedStatuses: [.success])
    
    static let applying = DeploymentStage(toDoName: "Update", inProgressName: "Applying Update...", finishedName: "Updated", symbolName: "bandage", inProgressStatus: .applying, completedStatuses: [.success])
    
    static let completed = DeploymentStage(toDoName: "Complete", inProgressName: "Completing...", finishedName: "Completed", symbolName: "checkmark", inProgressStatus: .applying, completedStatuses: [.success])
    
    // MARK: CaseIterable
    
    static var allCases: [DeploymentStage] = [.building, .downloading, .verifying, .uploading, .confirming, .applying, .completed]
}
