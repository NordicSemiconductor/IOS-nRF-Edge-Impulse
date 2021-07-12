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
    
    @ObservedObject private var viewState = DeploymentViewState()
    
    // MARK: - viewBuilder
    
    var body: some View {
        VStack {
            switch viewState.status {
            case .buildingModel(_), .downloadingModel(_), .error(_):
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

// MARK: - Logic

fileprivate extension DeploymentView {
    
    func attemptToBuild() {
        guard let currentProject = appData.selectedProject,
              let apiToken = appData.apiToken else { return }
        viewState.sendBuildRequest(for: currentProject, using: apiToken) { [self] response, error in
            guard let response = response else {
                if let error = error {
                    self.viewState.status = .error(error)
                }
                return
            }
            self.viewState.status = .buildingModel(response.id)
        }
    }
    
    func retry() {
        viewState.status = .idle
        attemptToConnect()
    }
    
    func attemptToConnect() {
        guard viewState.isReadyToConnect,
              let currentProject = appData.selectedProject,
              let socketToken = appData.projectSocketTokens[currentProject] else {
            // TODO: Error: Token missing.
            return
        }
        viewState.connect(using: socketToken)
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
