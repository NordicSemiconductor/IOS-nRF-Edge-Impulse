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
                DeploymentProgressView()
                    .environmentObject(viewState)
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
                Button(viewState.buildButtonText, action: buttonAction)
                    .centerTextInsideForm()
                    .disabled(!viewState.buildButtonEnable)
                #if os(iOS)
                    .foregroundColor(viewState.buildButtonEnable ? .positiveActionButtonColor : .disabledTextColor)
                #endif
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
