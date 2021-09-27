//
//  DeploymentProgressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import SwiftUI

struct DeploymentProgressView: View {
    
    @EnvironmentObject var viewState: DeploymentViewState
    
    var body: some View {
        FormIniOSListInMacOS {
            Section(header: Text("Progress")) {
                ForEach(DeploymentStage.allCases) { stage in
                    DeploymentStageView(stage: stage)
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
