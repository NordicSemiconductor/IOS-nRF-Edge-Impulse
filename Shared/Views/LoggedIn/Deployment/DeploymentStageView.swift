//
//  DeploymentStageView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/9/21.
//

import SwiftUI

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
    let isCompleted: (DeploymentViewState.JobStatus) -> Bool
    let isInProgress: (DeploymentViewState.JobStatus) -> Bool
    
    private init(name: String, isCompleted: @escaping (DeploymentViewState.JobStatus) -> Bool,
                 isInProgress: @escaping (DeploymentViewState.JobStatus) -> Bool) {
        self.id = name
        self.isCompleted = isCompleted
        self.isInProgress = isInProgress
    }
    
    // Cases
    
    static let building = DeploymentStage(name: "Building...", isCompleted: { status in
        switch status {
        case .downloadingModel, .unpackingModelData, .performingFirmwareUpdate, .success:
            return true
        default:
            return false
        }
    }, isInProgress: { status in
        guard case .buildingModel(_) = status else {
            return false
        }
        return true
    })
    
    static let downloading = DeploymentStage(name: "Downloading...", isCompleted: { status in
        switch status {
        case .unpackingModelData, .performingFirmwareUpdate, .success:
            return true
        default:
            return false
        }
    }, isInProgress: { status in
        guard case .downloadingModel = status else {
            return false
        }
        return true
    })
    
    static let verifying = DeploymentStage(name: "Verifying...", isCompleted: { status in
        switch status {
        case .performingFirmwareUpdate, .success:
            return true
        default:
            return false
        }
    }, isInProgress: { status in
        guard case .unpackingModelData = status else {
            return false
        }
        return true
    })
    
    static let uploading = DeploymentStage(name: "Uploading...", isCompleted: { status in
        guard case .success = status else {
            return false
        }
        return true
    }, isInProgress: { status in
        guard case .performingFirmwareUpdate = status else {
            return false
        }
        return true
    })
    
    // CaseIterable
    
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
