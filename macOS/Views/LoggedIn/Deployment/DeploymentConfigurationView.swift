//
//  DeploymentConfigurationView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 21/7/21.
//

import SwiftUI

// MARK: - DeploymentConfigurationView

struct DeploymentConfigurationView: View {
    
    // MARK: Properties
    
    @EnvironmentObject var deviceData: DeviceData
    @EnvironmentObject var viewState: DeploymentViewState
    
    // MARK: View
    
    var body: some View {
        ScrollView {
            Section(header: Text("Target").bold()) {
                ConnectedDevicePicker($viewState.selectedDevice)
                    .onAppear(perform: selectFirstAvailableDeviceHandler)
            }
            
            Divider()
                .padding(.vertical)
            
            Section(header: Text("Configuration").bold()) {
                MultiColumnView {
                    Text("Compiler")
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle(isOn: $viewState.enableEONCompiler, label: {
                            Text("Enable EON™ Compiler")
                        })
                        .toggleStyle(CheckboxToggleStyle())
                    }
                    
                    Text("")
                    Text("Same accuracy, up to 50% less memory. Open source.")
                        .font(.callout)
                        .foregroundColor(.nordicMiddleGrey)
                }
                .withTabBarStyle()
                
                MultiColumnView {
                    Text("Classifier")
                    Picker(selection: $viewState.optimization, label: EmptyView()) {
                        ForEach(DeploymentViewState.Classifier.allCases, id: \.self) { classifier in
                            Text(classifier.description)
                                .tag(classifier)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .padding(.vertical, 6)
                    
                    Text("")
                    Text(DeploymentViewState.Classifier.userCaption)
                        .font(.callout)
                        .foregroundColor(.nordicMiddleGrey)
                }
                .withTabBarStyle()
                .padding(.top)
                
                MultiColumnView {
                    Text("Build")
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle(isOn: $viewState.enableCachedServerBuilds, label: {
                            Text("Enable Cached Builds")
                        })
                        .toggleStyle(.checkbox)
                    }
                    
                    Text("")
                    Text("When enabled, we will check if there's an existing build in the Server matching your configuration.")
                        .font(.callout)
                        .foregroundColor(.nordicMiddleGrey)
                }
                .withTabBarStyle()
                .padding(.top)
            }
        }
        .padding()
        .setTitle("Deployment")
    }
}

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

struct DeploymentConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeploymentConfigurationView()
                .environmentObject(Preview.mockScannerData)
                .environmentObject(DeploymentViewState())
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
