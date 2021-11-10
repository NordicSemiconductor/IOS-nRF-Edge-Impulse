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

// MARK: - Preview

#if DEBUG
//struct DeploymentStageView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeploymentStageView()
//    }
//}
#endif
