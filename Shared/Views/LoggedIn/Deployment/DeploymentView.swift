//
//  DeploymentView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import SwiftUI

struct DeploymentView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: - State
    
    @ObservedObject private var viewState = DeploymentViewState()
    
    // MARK: - viewBuilder
    
    var body: some View {
        Form {
            Section(header: Text("Device")) {
                if appData.devices.count > 0 {
                    Picker("Selected", selection: $viewState.selectedDevice) {
                        ForEach(appData.devices, id: \.self) { device in
                            Text(device.id.uuidString).tag(device)
                        }
                    }
                    .setAsComboBoxStyle()
                } else {
                    Text("No Devices Scanned.")
                        .foregroundColor(Assets.middleGrey.color)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Section(header: Text("Compiler")) {
                Picker("Selected", selection: $viewState.compiler) {
                    ForEach(DeploymentViewState.Compiler.allCases, id: \.self) { compiler in
                        Text(compiler.rawValue).tag(compiler)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Optimization")) {
                Picker("Selected", selection: $viewState.optimizationLevel) {
                    ForEach(DeploymentViewState.Optimization.allCases, id: \.self) { optimization in
                        Text(optimization.rawValue).tag(optimization)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            ProgressView(value: viewState.progress, total: 100.0)
            
            Button("Deploy") {
                deploy()
            }
            .centerTextInsideForm()
            
            Section(header: Text("Mode")) {
                Picker("Selected", selection: $viewState.duration) {
                    ForEach(DeploymentViewState.Duration.allCases, id: \.self) { continuous in
                        Text(continuous.rawValue).tag(continuous)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Button("Run Impulse") {
                runImpulse()
            }
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
                .environmentObject(ProjectList_Previews.noDevicesAppData)
        }
        .setBackgroundColor(.blue)
    }
}
#endif
