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
    
    #if os(OSX)
    var shouldShowIndeterminateProgressBar: Bool {
        switch viewState.status {
        case .socketConnecting, .buildRequestSent, .downloadingModel:
            return true
        default:
            return false
        }
    }
    #endif
    
    var body: some View {
        VStack {
            #if os(OSX)
            NSProgressView(value: $viewState.progress, maxValue: 100.0,
                           isIndeterminate: shouldShowIndeterminateProgressBar)
                .padding(.horizontal)
            #else
            ProgressView(value: viewState.progress, total: 100.0)
                .padding(.horizontal)
            #endif
            
            viewState.status.view
            
            switch viewState.status {
            case .error(_):
                Button("Retry", action: retryAction)
                    .modifier(CircularButtonShape(backgroundAsset: .blue))
                    .centerTextInsideForm()
                    .foregroundColor(.primary)
            default:
                Button("Build", action: buildAction)
                    .modifier(CircularButtonShape(backgroundAsset: viewState.buildButtonEnable
                                                    ? .blue : .middleGrey))
                    .centerTextInsideForm()
                    .foregroundColor(viewState.buildButtonEnable ? .primary : Assets.middleGrey.color)
                    .disabled(!viewState.buildButtonEnable)
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
