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
                Text(name)
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
                    ProgressView(value: viewState.progress, total: 100.0)
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
    let symbolName: String
    
    private let isCompletedStatuses: [DeploymentViewState.JobStatus]
    private let inProgressStatus: DeploymentViewState.JobStatus
    
    // MARK: Init
    
    private init(name: String, symbolName: String,
                 inProgressStatus: DeploymentViewState.JobStatus,
                 completedStatuses: [DeploymentViewState.JobStatus]) {
        self.id = name
        self.symbolName = symbolName
        self.inProgressStatus = inProgressStatus
        self.isCompletedStatuses = completedStatuses
    }
    
    // MARK: API
    
    func isCompleted(_ status: DeploymentViewState.JobStatus) -> Bool {
        return isCompletedStatuses.contains(status)
    }
    
    func isInProgress(_ status: DeploymentViewState.JobStatus) -> Bool {
        return status == inProgressStatus
    }
    
    // MARK: Cases
    
    static let building = DeploymentStage(name: "Building...", symbolName: "hammer", inProgressStatus: .buildingModel(5), completedStatuses: [.downloadingModel, .unpackingModelData, .uploading(1), .applying, .confirming, .success])

    static let downloading = DeploymentStage(name: "Downloading...", symbolName: "square.and.arrow.down", inProgressStatus: .downloadingModel, completedStatuses: [.unpackingModelData, .uploading(1), .applying, .confirming, .success])
    
    static let verifying = DeploymentStage(name: "Verifying...", symbolName: "list.bullet", inProgressStatus: .unpackingModelData, completedStatuses: [.uploading(1), .applying, .confirming, .success])
    
    static let uploading = DeploymentStage(name: "Uploading...", symbolName: "square.and.arrow.up", inProgressStatus: .uploading(5), completedStatuses: [.success])
    
    static let confirming = DeploymentStage(name: "Confirming...", symbolName: "metronome", inProgressStatus: .confirming, completedStatuses: [.success])
    
    static let applying = DeploymentStage(name: "Applying Update...", symbolName: "bandage", inProgressStatus: .applying, completedStatuses: [.success])
    
    static let completed = DeploymentStage(name: "Completed!", symbolName: "checkmark", inProgressStatus: .applying, completedStatuses: [.success])
    
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
