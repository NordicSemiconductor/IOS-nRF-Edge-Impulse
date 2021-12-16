//
//  DeploymentConfigurationView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 27/9/21.
//

import SwiftUI

struct DeploymentConfigurationView: View {
    
    @EnvironmentObject var deviceData: DeviceData
    @EnvironmentObject var viewState: DeploymentViewState
    
    var body: some View {
        Section(header: Text("Device")) {
            ConnectedDevicePicker($viewState.selectedDeviceHandler)
                .onAppear(perform: selectFirstAvailableDeviceHandler)
        }
        
        Section(header: Text("Optimizations")) {
            Toggle(isOn: $viewState.enableEONCompiler, label: {
                Text("Enable EON™ Compiler")
            })
            .toggleStyle(SwitchToggleStyle(tint: Assets.blue.color))
            
            Text("Same accuracy, up to 50% less memory. Open source.")
                .font(.caption)
                .foregroundColor(Assets.middleGrey.color)
        }
        
        Section(header: Text("Classifier")) {
            Picker("Classifier", selection: $viewState.optimization) {
                ForEach(DeploymentViewState.Classifier.allCases, id: \.self) { classifier in
                    DeploymentClassifierView(classifier)
                        .tag(classifier)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 75, alignment: .leading)
            
            #if os(iOS)
            Text(DeploymentViewState.Classifier.attributedUserCaption)
                .font(.caption)
                .foregroundColor(Assets.middleGrey.color)
            #else
            Text(DeploymentViewState.Classifier.userCaption)
                .font(.caption)
                .foregroundColor(Assets.middleGrey.color)
            #endif
        }
        
        Section(header: Text("Build")) {
            Toggle(isOn: $viewState.enableCachedServerBuilds, label: {
                Text("Enable Cached Builds")
            })
            .toggleStyle(SwitchToggleStyle(tint: Assets.blue.color))
            
            Text("When enabled, we will check if there's an existing build in the Server matching your configuration.")
                .font(.caption)
                .foregroundColor(Assets.middleGrey.color)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            DeploymentConfigurationView()
        }
        .environmentObject(Preview.mockRegisteredDevices)
        .environmentObject(DeploymentViewState())
    }
}
#endif
