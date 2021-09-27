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

// MARK: - Preview

#if DEBUG
struct DeploymentConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        DeploymentConfigurationView()
    }
}
#endif
