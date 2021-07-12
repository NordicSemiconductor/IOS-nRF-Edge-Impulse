//
//  DeploymentViewProgressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import SwiftUI

struct DeploymentViewProgressView: View {
    
    @EnvironmentObject var viewState: DeploymentViewState
    
    let retryAction: () -> ()
    let buildAction: () -> ()
    
    var body: some View {
        Form {
            ProgressView(value: viewState.progress, total: 100.0)
            viewState.status.view
            switch viewState.status {
            case .error(_):
                Button("Retry", action: retryAction)
                    .centerTextInsideForm()
                    .foregroundColor(.primary)
            default:
                Button("Build", action: buildAction)
                    .centerTextInsideForm()
                    .foregroundColor(viewState.buildButtonEnable ? .primary : Assets.middleGrey.color)
                    .disabled(!viewState.buildButtonEnable)
            }
        }
        .introspectTableView { tableView in
            tableView.isScrollEnabled = false
        }
        .frame(height: 200)
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentViewControlsView_Previews: PreviewProvider {
    
    static var noOp: () -> () = { }
    
    static var previews: some View {
        Group {
            DeploymentViewProgressView(retryAction: noOp, buildAction: noOp)
                .environmentObject(DeploymentViewState())
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
