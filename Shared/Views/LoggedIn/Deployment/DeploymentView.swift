//
//  DeploymentView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import SwiftUI

struct DeploymentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var scannerData: ScannerData
    
    // MARK: - State
    
    @ObservedObject private var viewState = DeploymentViewState()
    
    // MARK: - viewBuilder
    
    var body: some View {
        Form {
            Section(header: Text("Device")) {
                let connectedDevices = scannerData.allConnectedAndReadyToUseDevices()
                if connectedDevices.hasItems {
                    Picker("Selected", selection: $viewState.selectedDevice) {
                        ForEach(connectedDevices, id: \.self) { device in
                            Text(device.name)
                                .tag(device)
                        }
                    }
                    .setAsComboBoxStyle()
                } else {
                    Text("No Devices Scanned.")
                        .foregroundColor(Assets.middleGrey.color)
                        .multilineTextAlignment(.leading)
                }
            }
            
            ProgressView(value: viewState.progress, total: 100.0)
            
            Button("Deploy", action: viewState.deploy)
                .centerTextInsideForm()
                .foregroundColor(.primary)
            
            Section(header: Text("Mode")) {
                Picker("Selected", selection: $viewState.duration) {
                    ForEach(DeploymentViewState.Duration.allCases, id: \.self) { continuous in
                        Text(continuous.rawValue).tag(continuous)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button("Run Impulse", action: viewState.runImpulse)
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
