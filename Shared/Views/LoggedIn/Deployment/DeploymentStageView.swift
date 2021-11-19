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
                    Text(viewState.lastLogMessage.line)
                        .font(.caption)
                        .lineLimit(1)
                    #if os(macOS)
                        .padding(.top, 1)
                    #endif

                    #if os(OSX)
                    NSProgressView(value: $viewState.progress, maxValue: 100.0,
                                   isIndeterminate: viewState.progressManager.isIndeterminate)
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
}

// MARK: - Preview

#if DEBUG
//struct DeploymentStageView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeploymentStageView()
//    }
//}
#endif
