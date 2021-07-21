//
//  DeploymentView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import SwiftUI
import Combine

struct DeploymentView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: - State
    
    @StateObject internal var viewState = DeploymentViewState()
    
    // MARK: - viewBuilder
    
    var body: some View {
        VStack {
            switch viewState.status {
            case .buildingModel(_), .downloadingModel, .performingFirmwareUpdate, .error(_):
                DeploymentLogView()
                    .environmentObject(viewState)
                    .padding(.top)
            default:
                DeploymentConfigurationView()
                    .environmentObject(viewState)
                    .padding(.bottom)
            }
            
            DeploymentProgressView(retryAction: retry, buildAction: attemptToBuild)
                .environmentObject(viewState)
        }
        .background(Color.formBackground)
        .onAppear() {
            attemptToConnect()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            DeploymentView()
                .setTitle(Tabs.Deployment.description)
                .wrapInNavigationViewForiOS()
                .environmentObject(Preview.noDevicesAppData)
                .environmentObject(Preview.noDevicesScannerData)    
        }
    }
}
#endif
