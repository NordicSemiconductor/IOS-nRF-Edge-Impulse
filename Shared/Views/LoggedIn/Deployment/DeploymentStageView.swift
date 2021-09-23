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
    
    let name: String
    let stage: DeploymentStage
    
    init(stage: DeploymentStage) {
        name = stage.id
        self.stage = stage
    }
    
    var deploymentFailed: Bool {
        guard case .error(_) = viewState.status else { return false }
        return true
    }
    
    var stageColor: Color {
        guard !deploymentFailed else { return Assets.red.color }
        if stage.isCompleted(viewState.status) {
            return Assets.grass.color
        } else if stage.isInProgress(viewState.status) {
            return Assets.sun.color
        }
        return .disabledTextColor
    }
    
    var body: some View {
        HStack {
            VStack {
                if deploymentFailed {
                    Image(systemName: "xmark")
                        .foregroundColor(stageColor)
                } else if stage.isCompleted(viewState.status) {
                    Image(systemName: "checkmark")
                        .foregroundColor(stageColor)
                } else if stage.isInProgress(viewState.status) {
                    ProgressView()
                        .foregroundColor(stageColor)
                    #if os(macOS)
                        .scaleEffect(0.5, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.red))
                    #endif
                } else {
                    EmptyView()
                }
            }
            .frame(width: 20, height: 20)
            
            VStack(alignment: .leading) {
                Text(name)
                    .foregroundColor(stageColor)
                
                if stage.isInProgress(viewState.status) {
                    Text(viewState.lastLogMessage.line)
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.top, 1)
                }
            }
            #if os(macOS)
            .padding(.leading, stage.isInProgress(viewState.status) ? 8 : 0)
            #endif
        }
    }
}

// MARK: - DeploymentStage

struct DeploymentStage: Identifiable, CaseIterable {
    
    let id: String
    private let isCompletedStatuses: [DeploymentViewState.JobStatus]
    private let inProgressStatus: DeploymentViewState.JobStatus
    
    // MARK: Init
    
    private init(name: String, inProgressStatus: DeploymentViewState.JobStatus,
                 completedStatuses: [DeploymentViewState.JobStatus]) {
        self.id = name
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
    
    static let building = DeploymentStage(name: "Building...", inProgressStatus: .buildingModel(5), completedStatuses: [.downloadingModel, .unpackingModelData, .performingFirmwareUpdate, .success])

    static let downloading = DeploymentStage(name: "Downloading...", inProgressStatus: .downloadingModel, completedStatuses: [.unpackingModelData, .performingFirmwareUpdate, .success])
    
    static let verifying = DeploymentStage(name: "Verifying...", inProgressStatus: .unpackingModelData, completedStatuses: [.performingFirmwareUpdate, .success])
    
    static let uploading = DeploymentStage(name: "Uploading...", inProgressStatus: .performingFirmwareUpdate, completedStatuses: [.success])
    
    static let confirming = DeploymentStage(name: "Confirming...", inProgressStatus: .performingFirmwareUpdate, completedStatuses: [.success])
    
    static let applying = DeploymentStage(name: "Applying Update...", inProgressStatus: .performingFirmwareUpdate, completedStatuses: [.success])
    
    static let completed = DeploymentStage(name: "Completed...", inProgressStatus: .performingFirmwareUpdate, completedStatuses: [.success])
    
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
