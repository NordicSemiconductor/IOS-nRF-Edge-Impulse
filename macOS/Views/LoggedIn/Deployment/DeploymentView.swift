//
//  DeploymentView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 12/5/21.
//

import SwiftUI

struct DeploymentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var scannerData: ScannerData
    
    // MARK: - State
    
    @ObservedObject private var viewState = DeploymentViewState()
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            Section(header: Text("Target").bold()) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 0, pinnedViews: []) {
                    Text("Connected Device: ")
                    Picker(selection: $viewState.selectedDevice, label: EmptyView()) {
                        let connectedDevices = scannerData.allConnectedAndReadyToUseDevices()
                        if connectedDevices.hasItems {
                            ForEach(connectedDevices) { device in
                                Text(device.name).tag(device)
                            }
                        } else {
                            Text("--").tag(Constant.unselectedDevice)
                        }
                    }
                }
                
                ProgressView(value: viewState.progress, total: 100.0)
                
                Button("Deploy", action: viewState.deploy)
                    .foregroundColor(.primary)
            }
            
            Divider()
                .padding(.vertical)
            
            Section(header: Text("Mode").bold()) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 0, pinnedViews: []) {
                    Text("Selected: ")
                    Picker(selection: $viewState.duration, label: EmptyView()) {
                        ForEach(DeploymentViewState.Duration.allCases, id: \.self) { continuous in
                            Text(continuous.rawValue).tag(continuous)
                        }
                    }
                }
                
                ProgressView(value: viewState.progress, total: 100.0)
                
                Button("Run Impulse", action: viewState.runImpulse)
                    .foregroundColor(.primary)
                    .padding(.vertical)
            }
        }
        .padding(16)
    }
    
    // MARK: Column Setup
    
    private var columns: [GridItem] = [
        GridItem(.fixed(120), spacing: 0),
        GridItem(.flexible(minimum: 200, maximum: .infinity), spacing: 0)
    ]
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
