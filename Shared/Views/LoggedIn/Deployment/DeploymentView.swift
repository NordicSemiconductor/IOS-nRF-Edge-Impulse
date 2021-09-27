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
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    @StateObject internal var viewState = DeploymentViewState()
    
    // MARK: - viewBuilder
    
    var body: some View {
        FormIniOSListInMacOS {
            if viewState.status.shouldShowProgressView {
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
            } else {
                DeploymentConfigurationView()
                    .environmentObject(viewState)
                    .environmentObject(deviceData)
            }
            
            #if os(macOS)
            Divider()
                .padding(.horizontal)
            #endif
            
            Section {
                switch viewState.status {
                case .success, .error(_):
                    Button("Retry", action: retry)
                        .centerTextInsideForm()
                        .disabled(!$viewState.buildButtonEnable.wrappedValue)
                default:
                    Button("Build", action: connectThenBuild)
                        .centerTextInsideForm()
                        .disabled(!$viewState.buildButtonEnable.wrappedValue)
                    #if os(iOS)
                        .foregroundColor($viewState.buildButtonEnable.wrappedValue ? .positiveActionButtonColor : .disabledTextColor)
                    #endif
                }
            }
        }
        .background(Color.formBackground)
        #if os(iOS)
        .padding(.top)
        #endif
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
