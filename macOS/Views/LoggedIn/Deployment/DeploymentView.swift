//
//  DeploymentView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 12/5/21.
//

import SwiftUI

struct DeploymentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    @ObservedObject internal var viewState = DeploymentViewState()
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            Section(header: Text("Target").bold()) {
                MultiColumnView {
                    Text("Connected Device: ")
                    Picker(selection: $viewState.selectedDevice, label: EmptyView()) {
                        let connectedDevices = deviceData.allConnectedAndReadyToUseDevices()
                        if connectedDevices.hasItems {
                            ForEach(connectedDevices.compactMap({ $0.device })) { device in
                                Text(device.name)
                                    .tag(device)
                            }
                        } else {
                            Text("--").tag(Constant.unselectedScanResult)
                        }
                    }
                }
                
                DeploymentProgressView(retryAction: retry, buildAction: attemptToBuild)
                    .environmentObject(viewState)
            }
            
            Divider()
                .padding(.vertical)
            
//            Section(header: Text("Mode").bold()) {
//                MultiColumnView {
//                    Text("Selected: ")
//                    Picker(selection: $viewState.duration, label: EmptyView()) {
//                        ForEach(DeploymentViewState.Duration.allCases, id: \.self) { continuous in
//                            Text(continuous.rawValue).tag(continuous)
//                        }
//                    }
//                }
//                
//                ProgressView(value: viewState.progress, total: 100.0)
//                
//                Button("Run Impulse", action: viewState.runImpulse)
//                    .foregroundColor(.primary)
//                    .padding(.vertical)
//            }
        }
        .padding(16)
        .frame(maxWidth: 320)
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        DeploymentView()
            .environmentObject(Preview.noDevicesAppData)
            .environmentObject(Preview.noDevicesScannerData)
    }
}
#endif
