//
//  DeploymentStageView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/9/21.
//

import SwiftUI

// MARK: - DeploymentStageView

struct DeploymentStageView: View {
    
    @EnvironmentObject var viewState: DeploymentViewState
    
    private let name: String
    private let stage: DeploymentStage
    
    // MARK: Init
    
    init(stage: DeploymentStage) {
        name = stage.id
        self.stage = stage
    }
    
    // MARK: View
    
    var body: some View {
        HStack {
            if stage.isInProgress(viewState.status) {
                CircularProgressView()
            }
            
            Image(systemName: stage.symbolName)
                .foregroundColor(stageColor)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(stage.name(for: viewState.status))
                    .foregroundColor(stageColor)
                
                if stage.isInProgress(viewState.status) {
                    Text(viewState.lastLogMessage.line)
                        .font(.caption)
                        .lineLimit(1)
                    #if os(macOS)
                        .padding(.top, 1)
                    #endif
                    
                    #if os(OSX)
                    NSProgressView(value: $viewState.progress, maxValue: 100.0,
                                   isIndeterminate: viewState.progressShouldBeIndeterminate)
                        .padding(.horizontal)
                    #else
                    UILinearProgressView(value: $viewState.progress)
                        .padding(.top, 2)
                    #endif
                }
            }
        }
    }
    
    // MARK: API
    
    var deploymentFailed: Bool {
        guard case .error(_) = viewState.status else { return false }
        return true
    }
    
    var stageColor: Color {
        guard !deploymentFailed else { return Assets.red.color }
        if stage.isCompleted(viewState.status) {
            return .succcessfulActionButtonColor
        } else if stage.isInProgress(viewState.status) {
            return Assets.sun.color
        }
        return .disabledTextColor
    }
}

// MARK: - DeploymentStage

struct DeploymentStage: Identifiable, CaseIterable {
    
    let id: String
    let toDoName: String
    let inProgressName: String
    let finishedName: String
    let symbolName: String
    
    private let isCompletedStatuses: [DeploymentViewState.JobStatus]
    private let inProgressStatus: DeploymentViewState.JobStatus
    
    // MARK: Init
    
    private init(toDoName: String, inProgressName: String, finishedName: String,
                 symbolName: String, inProgressStatus: DeploymentViewState.JobStatus,
                 completedStatuses: [DeploymentViewState.JobStatus]) {
        self.id = toDoName
        self.toDoName = toDoName
        self.inProgressName = inProgressName
        self.finishedName = finishedName
        self.symbolName = symbolName
        self.inProgressStatus = inProgressStatus
        self.isCompletedStatuses = completedStatuses
    }
    
    // MARK: API
    
    func name(for status: DeploymentViewState.JobStatus) -> String {
        guard !isCompleted(status) else { return finishedName }
        return isInProgress(status) ? inProgressName : toDoName
    }
    
    func isCompleted(_ status: DeploymentViewState.JobStatus) -> Bool {
        return isCompletedStatuses.contains(status)
    }
    
    func isInProgress(_ status: DeploymentViewState.JobStatus) -> Bool {
        return status == inProgressStatus
    }
    
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

// MARK: - Preview

#if DEBUG
//struct DeploymentStageView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeploymentStageView()
//    }
//}
#endif
