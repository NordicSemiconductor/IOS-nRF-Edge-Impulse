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
            if viewState.status.shouldShowProgressView {
                DeploymentProgressView()
                    .environmentObject(viewState)
                    .padding(.top)
            } else {
                DeploymentConfigurationView()
                    .environmentObject(viewState)
                    .padding(.bottom)
            }
            
            Divider()
                .padding(.horizontal)
            
            Section {
                switch viewState.status {
                case .success, .error(_):
                    Button("Retry", action: retry)
                        .padding()
                        .disabled(!$viewState.buildButtonEnable.wrappedValue)
                default:
                    Button("Build", action: connectThenBuild)
                        .padding()
                        .disabled(!$viewState.buildButtonEnable.wrappedValue)
                    #if os(iOS)
                        .foregroundColor($viewState.buildButtonEnable.wrappedValue ? .positiveActionButtonColor : .disabledTextColor)
                    #endif
                }
            }
        }
        .background(Color.formBackground)
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
