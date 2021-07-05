//
//  DeploymentView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import SwiftUI

struct DeploymentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    @ObservedObject private var viewState = DeploymentViewState()
    
    // MARK: - viewBuilder
    
    var body: some View {
        Form {
            Section(header: Text("Device")) {
                let connectedDevices = deviceData.allConnectedAndReadyToUseDevices()
                if connectedDevices.hasItems {
                    Picker("Selected", selection: $viewState.selectedDevice) {
                        ForEach(connectedDevices, id: \.self) { handler in
                            Text(handler.device.name)
                                .tag(handler.device)
                        }
                    }
                    .setAsComboBoxStyle()
                } else {
                    Text("No Devices Scanned.")
                        .foregroundColor(Assets.middleGrey.color)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Section(header: Text("Optimizations")) {
                Toggle(isOn: $viewState.enableEONCompiler, label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable EON™ Compiler")
                        Text("Same accuracy, up to 50% less memory. Open source.")
                            .font(.caption)
                            .foregroundColor(Assets.middleGrey.color)
                    }
                })
                .toggleStyle(SwitchToggleStyle(tint: Assets.blue.color))
            }
            
            Section(header: Text("Classifier")) {
                Picker("Classifier", selection: $viewState.optimization) {
                    ForEach(DeploymentViewState.Classifier.allCases, id: \.self) { classifier in
                        Text(classifier.rawValue).tag(classifier)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text("\(DeploymentViewState.Classifier.Quantized.rawValue) is recommended for best performance. ")
                    .font(.caption)
                    .foregroundColor(Assets.middleGrey.color)
            }
            
            ProgressView(value: viewState.progress, total: 100.0)
            
            Button("Build", action: viewState.build)
                .centerTextInsideForm()
                .foregroundColor(.primary)
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
