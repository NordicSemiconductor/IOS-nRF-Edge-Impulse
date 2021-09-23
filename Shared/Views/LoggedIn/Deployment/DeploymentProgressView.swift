//
//  DeploymentProgressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import SwiftUI

struct DeploymentProgressView: View {
    
    var deploymentStatus: Binding<DeploymentViewState.JobStatus>
    
    var body: some View {
        FormIniOSListInMacOS {
            ForEach(DeploymentStage.allCases) { stage in
                DeploymentStageView(stage: stage, status: deploymentStatus.wrappedValue)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentProgressStageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            DeploymentProgressView()
//                .environmentObject(DeploymentViewState())
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif