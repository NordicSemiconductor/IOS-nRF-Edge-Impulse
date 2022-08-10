//
//  DeploymentProgressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import SwiftUI

struct DeploymentProgressView: View {
    
    @EnvironmentObject var viewState: DeploymentViewState
    
    var body: some View {
        Section(header: Text("Progress")) {
            ForEach(viewState.progressManager.stages) { stage in
                DeploymentStageView(stage: stage,
                                    progressManager: viewState.progressManager,
                                    logLine: viewState.lastLogMessage.line)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

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
