//
//  DeploymentConfigurationView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 21/7/21.
//

import SwiftUI

struct DeploymentConfigurationView: View {
    
    @EnvironmentObject var deviceData: DeviceData
    @EnvironmentObject var viewState: DeploymentViewState
    
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
                        .font(.caption)
                        .foregroundColor(Assets.middleGrey.color)
                }
                
                MultiColumnView {
                    Text("Classifier")
                    Picker(selection: $viewState.optimization, label: EmptyView()) {
                        ForEach(DeploymentViewState.Classifier.allCases, id: \.self) { classifier in
                            Text(classifier.rawValue).tag(classifier)
                        }
                    }
                    .pickerStyle(RadioGroupPickerStyle())
                    .horizontalRadioGroupLayout()
                    .padding(.vertical, 6)
                    
                    Text("")
                    Text("\(DeploymentViewState.Classifier.Quantized.rawValue) is recommended for best performance. ")
                        .font(.caption)
                        .foregroundColor(Assets.middleGrey.color)
                }
                
                
            }
        }
        .padding()
        .setTitle("Deployment")
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
