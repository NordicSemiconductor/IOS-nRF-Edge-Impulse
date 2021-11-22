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
    
    // MARK: - View
    
    var body: some View {
        FormIniOSListInMacOS {
            if viewState.status.shouldShowConfigurationView {
                DeploymentConfigurationView()
                    .environmentObject(viewState)
                    .environmentObject(deviceData)
            } else {
                DeploymentProgressView()
                    .environmentObject(viewState)
            }
            
            if let error = viewState.error {
                DeploymentErrorView(error: error)
            }
            
            #if os(macOS)
            Divider()
                .padding(.horizontal)
            #endif
            
            Section {
                Button(viewState.buildButtonText, action: buttonAction)
                    .centerTextInsideForm()
                    .disabled(!viewState.buildButtonEnable)
                #if os(iOS)
                    .foregroundColor(viewState.buildButtonEnable
                                     ? .positiveActionButtonColor : .disabledTextColor)
                #endif
            }
        }
        #if os(iOS)
        .padding(.top)
        #endif
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
