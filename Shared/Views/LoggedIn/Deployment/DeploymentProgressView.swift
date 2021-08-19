//
//  DeploymentProgressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import SwiftUI

struct DeploymentProgressView: View {
    
    @EnvironmentObject var viewState: DeploymentViewState
    
    let retryAction: () -> ()
    let buildAction: () -> ()
    
    var body: some View {
        VStack {
            switch viewState.status {
            case .error(_):
                ReusableProgressView(progress: $viewState.progress, isIndeterminate: $viewState.progressShouldBeIndeterminate, statusText: $viewState.statusText, statusColor: viewState.status.color, buttonText: "Retry", buttonEnabled: viewState.buildButtonEnable, buttonAction: retryAction)
            default:
                ReusableProgressView(progress: $viewState.progress, isIndeterminate: $viewState.progressShouldBeIndeterminate, statusText: $viewState.statusText, statusColor: viewState.status.color, buttonText: "Build", buttonEnabled: viewState.buildButtonEnable, buttonAction: buildAction)
            }
        }
        .padding(.horizontal)
        .frame(height: 120)
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentControlsView_Previews: PreviewProvider {
    
    static var noOp: () -> () = { }
    
    static var previews: some View {
        Group {
            DeploymentProgressView(retryAction: noOp, buildAction: noOp)
                .environmentObject(DeploymentViewState())
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
