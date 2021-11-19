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
    let isIndeterminate: Bool
    
    private(set) var isInProgress: Bool
    private(set) var encounteredAnError: Bool
    private(set) var isCompleted: Bool
    
    // MARK: Init
    
    private init(toDoName: String, inProgressName: String, finishedName: String,
                 symbolName: String, isIndeterminate: Bool, inProgressStatus: DeploymentViewState.JobStatus,
                 completedStatuses: [DeploymentViewState.JobStatus]) {
        self.id = toDoName
        self.toDoName = toDoName
        self.inProgressName = inProgressName
        self.finishedName = finishedName
        self.symbolName = symbolName
        self.isIndeterminate = isIndeterminate
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
    
    static let building = DeploymentStage(toDoName: "Build", inProgressName: "Building...", finishedName: "Built", symbolName: "hammer", isIndeterminate: false, inProgressStatus: .buildingModel(5), completedStatuses: [.downloadingModel, .unpackingModelData, .uploading(1), .applying, .confirming, .success])

    static let downloading = DeploymentStage(toDoName: "Download", inProgressName: "Downloading...", finishedName: "Downloaded", symbolName: "square.and.arrow.down", isIndeterminate: false, inProgressStatus: .downloadingModel, completedStatuses: [.unpackingModelData, .uploading(1), .applying, .confirming, .success])
    
    static let verifying = DeploymentStage(toDoName: "Verify", inProgressName: "Verifying...", finishedName: "Verified", symbolName: "list.bullet", isIndeterminate: true, inProgressStatus: .unpackingModelData, completedStatuses: [.uploading(1), .applying, .confirming, .success])
    
    static let uploading = DeploymentStage(toDoName: "Upload", inProgressName: "Uploading...", finishedName: "Uploaded", symbolName: "square.and.arrow.up", isIndeterminate: false, inProgressStatus: .uploading(5), completedStatuses: [.success])
    
    static let confirming = DeploymentStage(toDoName: "Confirm", inProgressName: "Confirming...", finishedName: "Confirmed", symbolName: "metronome", isIndeterminate: true, inProgressStatus: .confirming, completedStatuses: [.success])
    
    static let applying = DeploymentStage(toDoName: "Update", inProgressName: "Applying Update...", finishedName: "Updated", symbolName: "bandage", isIndeterminate: true, inProgressStatus: .applying, completedStatuses: [.success])
    
    static let completed = DeploymentStage(toDoName: "Complete", inProgressName: "Completing...", finishedName: "Completed", symbolName: "checkmark", isIndeterminate: true, inProgressStatus: .applying, completedStatuses: [.success])
    
    // MARK: CaseIterable
    
    static var allCases: [DeploymentStage] = [.building, .downloading, .verifying, .uploading, .confirming, .applying, .completed]
}
