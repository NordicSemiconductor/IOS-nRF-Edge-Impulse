//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    let project: Project
    
    @EnvironmentObject var appData: AppData
    
    @State private var label = ""
    @State private var selectedDeviceIndex = 0
    @State private var selectedSensorIndex = 0
    @State private var sampleLength = 10000
    @State private var selectedFrequencyIndex = 1
    
    var sampleLengthAndFrequencyDisabled: Bool {
        Sensor.allCases[selectedSensorIndex] == .Camera
    }
    
    var startSamplingDisabled: Bool {
        label.count < 1 || appData.devices.isEmpty
    }
    
    var body: some View {
        Form {
            Section(header: Text("Project")) {
                Text("\(project.name)")
                    .font(.body)
                    .foregroundColor(Assets.middleGrey.color)
            }
            
            Section(header: Text("Device")) {
                if appData.devices.count > 0 {
                    Picker("Selected", selection: $selectedDeviceIndex) {
                        ForEach(appData.devices) { device in
                            Text(device.id.uuidString).tag(device.id)
                        }
                    }
                    .setAsComboBoxStyle()
                } else {
                    Text("No Devices Scanned.")
                        .foregroundColor(Assets.middleGrey.color)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Section(header: Text("Label")) {
                TextField("Label", text: $label)
            }

            Section(header: Text("Sensor")) {
                Picker("Type", selection: $selectedSensorIndex) {
                    ForEach(Sensor.allCases.indices) { i in
                        Text(Sensor.allCases[i].rawValue).tag(i)
                    }
                }
                .setAsComboBoxStyle()
            }
            
            Section(header: Text("Sample Length")) {
                Stepper(value: $sampleLength, in: 0...100000) {
                    Text("\(sampleLength, specifier: "%d") ms")
                }
                .disabled(sampleLengthAndFrequencyDisabled)
            }
            
            Section(header: Text("Frequency")) {
                Picker("Value", selection: $selectedFrequencyIndex) {
                    ForEach(Frequency.allCases.indices) { i in
                        Text(Frequency.allCases[i].description).tag(i)
                    }
                }
                .setAsComboBoxStyle()
                .disabled(sampleLengthAndFrequencyDisabled)
            }
            
            Button("Start Sampling") {
                startSampling()
            }
            .centerTextInsideForm()
            .disabled(startSamplingDisabled)
            .accentColor(startSamplingDisabled ? Assets.middleGrey.color : Assets.red.color)
        }
        .navigationTitle("Data Acquisition")
    }
}

private extension DataAcquisitionView {
    
    func startSampling() {
        
    }
}

// MARK: - Preview

#if DEBUG
struct NewSampleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DataAcquisitionView(project: ProjectList_Previews.previewProjects.first!)
                .environmentObject(ProjectList_Previews.projectsPreviewAppData)
                .previewDevice("iPhone 12 mini")
        }
        .setBackgroundColor(Assets.blue)
    }
}
#endif
