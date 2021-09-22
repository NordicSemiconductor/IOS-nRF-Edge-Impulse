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
            Section(header: Text("Logs")) {
                ForEach(viewState.logs, id: \.self) { log in
                    Text(log.line)
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentProgressView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeploymentProgressView()
                .environmentObject(DeploymentViewState())
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
