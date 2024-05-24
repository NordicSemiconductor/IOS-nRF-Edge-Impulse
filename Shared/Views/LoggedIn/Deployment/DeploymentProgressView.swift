//
//  DeploymentProgressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import SwiftUI
import iOS_Common_Libraries

struct DeploymentProgressView: View {
    
    @EnvironmentObject var viewState: DeploymentViewState
    
    var body: some View {
        Section("Progress") {
            ForEach(viewState.pipelineManager.stages) { stage in
                PipelineView(stage: stage, logLine: viewState.lastLogMessage.line,
                             accessoryLine: viewState.speedString)
                .accentColor(.universalAccentColor)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentProgressView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FormIniOSListInMacOS {
                DeploymentProgressView()
                    .environmentObject(DeploymentViewState())
            }
            .previewLayout(.sizeThatFits)
        }
    }
}
#endif
