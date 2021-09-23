//
//  DeploymentStageView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/9/21.
//

import SwiftUI

// MARK: - DeploymentStageView

struct DeploymentStageView: View {
    
    let name: String
    let stage: DeploymentStage
    let status: DeploymentViewState.JobStatus
    
    init(stage: DeploymentStage, status: DeploymentViewState.JobStatus) {
        name = stage.id
        self.stage = stage
        self.status = status
    }
    
    var body: some View {
        HStack {
            VStack {
                if stage.isCompleted(status) {
                    Image(systemName: "checkmark")
                        .foregroundColor(Assets.grass.color)
                } else if stage.isInProgress(status) {
                    ProgressView()
                        .foregroundColor(Assets.sun.color)
                } else {
                    EmptyView()
                }
            }
            .frame(width: 20, height: 20)
            
            Text(name)
                .padding(.horizontal)
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
    
    // MARK: CaseIterable
    
    static var allCases: [DeploymentStage] = [.building, .downloading, .verifying, .uploading]
}

// MARK: - Preview

#if DEBUG
//struct DeploymentStageView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeploymentStageView()
//    }
//}
#endif
