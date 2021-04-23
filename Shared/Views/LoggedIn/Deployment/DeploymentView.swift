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
            
            Button("Deploy", action: deploy)
                .centerTextInsideForm()
            
            Section(header: Text("Mode")) {
                Picker("Selected", selection: $viewState.duration) {
                    ForEach(DeploymentViewState.Duration.allCases, id: \.self) { continuous in
                        Text(continuous.rawValue).tag(continuous)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button("Run Impulse", action: runImpulse)
                .centerTextInsideForm()
        }
    }
}

extension DeploymentView {
    
    func deploy() {
        
    }
    
    func runImpulse() {
        
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            DeploymentView()
                .environmentObject(Preview.noDevicesAppData)
                .environmentObject(Preview.noDevicesScannerData)
        }
        .setBackgroundColor(.blue)
    }
}
#endif
