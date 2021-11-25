//
//  DeploymentStageView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/9/21.
//

import SwiftUI

// MARK: - DeploymentStageView

struct DeploymentStageView: View {
    
    private let stage: DeploymentStage
    private let logLine: String
    
    @ObservedObject private var progressManager: DeploymentProgressManager
    
    // MARK: Init
    
    init(stage: DeploymentStage, progressManager: DeploymentProgressManager, logLine: String) {
        self.stage = stage
        self.logLine = logLine
        self.progressManager = progressManager
    }
    
    // MARK: View
    
    var body: some View {
        HStack {
            if stage.isInProgress {
                CircularProgressView()
            }
            
            Image(systemName: stage.symbolName)
                .foregroundColor(stage.color)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(stage.name)
                    .foregroundColor(stage.color)

                if stage.isInProgress {
                    Text(logLine)
                        .font(.caption)
                        .lineLimit(1)
                    #if os(macOS)
                        .padding(.top, 1)
                    #endif

                    #if os(OSX)
                    NSProgressView(value: $progressManager.progress, maxValue: 100.0,
                                   isIndeterminate: progressManager.isIndeterminate)
                        .padding(.horizontal)
                    #else
                    UILinearProgressView(value: $progressManager.progress)
                        .padding(.top, 2)
                    #endif
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentStageView_Previews: PreviewProvider {
    
    static let onlineInProgress: DeploymentProgressManager = {
        let manager = DeploymentProgressManager()
        manager.started = true
        manager.inProgress(.online)
        return manager
    }()
    
    static var previews: some View {
        Group {
            DeploymentStageView(stage: onlineInProgress.currentStage, progressManager: onlineInProgress, logLine: "This is a test.")
        }
        .frame(width: 300)
    }
}
#endif
