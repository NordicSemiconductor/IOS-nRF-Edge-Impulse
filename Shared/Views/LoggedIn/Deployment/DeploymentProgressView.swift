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
            ForEach(viewState.stages) { stage in
                DeploymentStageView(stage: stage)
                    .environmentObject(viewState)
            }
        }
        
        switch viewState.status {
        case .error(let error):
            Section(header: Text("Error Description")) {
                // Align with the StageView items.
                HStack(spacing: 2) {
                    Image(systemName: "info")
                        .frame(width: 20, height: 20)
                    
                    Text(error.localizedDescription)
                }
                .padding(.leading, 2)
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
