//
//  DeploymentConfigurationView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import SwiftUI

struct DeploymentConfigurationView: View {
    
    @EnvironmentObject var deviceData: DeviceData
    @EnvironmentObject var viewState: DeploymentViewState
    
    var body: some View {
        FormIniOSListInMacOS {
            Section(header: Text("Device")) {
                let connectedDevices = deviceData.allConnectedAndReadyToUseDevices()
                if connectedDevices.hasItems {
                    Picker("Selected", selection: $viewState.selectedDeviceHandler) {
                        ForEach(connectedDevices) { handler in
                            Text(handler.userVisibleName)
                                .tag(handler.device)
                        }
                    }
                    .setAsComboBoxStyle()
                    .onAppear(perform: selectFirstAvailableDeviceHandler)
                } else {
                    Text("No Devices Scanned.")
                        .tag(Constant.unselectedDevice)
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
        }
    }
}

// MARK: - Preview

#if DEBUG
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
