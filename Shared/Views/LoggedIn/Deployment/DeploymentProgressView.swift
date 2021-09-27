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
            ForEach(DeploymentStage.allCases) { stage in
                DeploymentStageView(stage: stage)
                    .environmentObject(viewState)
            }
        }
        
        switch viewState.status {
        case .error(let error):
            Section(header: Text("Error Description")) {
                Label(error.localizedDescription, systemImage: "info")
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentProgressView_Previews: PreviewProvider {
    static var previews: some View {
        DeploymentProgressView()
    }
}
#endif
