//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    @EnvironmentObject var appData: AppData
    
    @State private var selectedProjectIndex = 0
    @State private var label = ""
    @State private var selectedDeviceIndex = 0
    @State private var selectedDataTypeIndex = 0
    @State private var selectedSensorIndex = 0
    @State private var sampleLength = 10000
    @State private var selectedFrequencyIndex = 1
    
    var sampleLengthAndFrequencyEnabled: Bool {
        Sensor.allCases[selectedSensorIndex] != .Camera
    }
    
    var startSamplingDisabled: Bool {
        appData.projects.isEmpty || label.count < 1 || appData.devices.isEmpty
    }
    
    var body: some View {
        Form {
            Section(header: Text("Project")) {
                if appData.projects.count > 0 {
                    Picker("Selected", selection: $selectedProjectIndex) {
                        ForEach(appData.projects.identifiableIndices) { i in
                            Text(appData.projects[i].name).tag(i)
                        }
                    }
                    .setAsComboBoxStyle()
                } else {
                    Text("No Projects for this User.")
                        .foregroundColor(Assets.middleGrey.color)
                }
            }
            
            Section(header: Text("Data Type")) {
                Picker("Type", selection: $selectedDataTypeIndex) {
                    ForEach(Sample.DataType.allCases.indices) { i in
                        Text(Sample.DataType.allCases[i].rawValue).tag(i)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Device")) {
                if appData.devices.count > 0 {
                    Picker("Selected", selection: $selectedDeviceIndex) {
                        ForEach(appData.devices.identifiableIndices) { i in
                            Text(appData.devices[i].id.uuidString).tag(i)
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
                if sampleLengthAndFrequencyEnabled {
                    Stepper(value: $sampleLength, in: 0...100000) {
                        Text("\(sampleLength, specifier: "%d") ms")
                    }
                } else {
                    Text("Unavailable for \(Sensor.Camera.rawValue) Sensor")
                        .foregroundColor(Assets.middleGrey.color)
                }
            }
            
            Section(header: Text("Frequency")) {
                if sampleLengthAndFrequencyEnabled {
                    Picker("Value", selection: $selectedFrequencyIndex) {
                        ForEach(Frequency.allCases.indices) { i in
                            Text(Frequency.allCases[i].description).tag(i)
                        }
                    }
                    .setAsComboBoxStyle()
                } else {
                    Text("Unavailable for \(Sensor.Camera.rawValue) Sensor")
                        .foregroundColor(Assets.middleGrey.color)
                }
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
    
    static let noDevicesAppData: AppData = {
        let appData = AppData()
        appData.projectsViewState = .showingProjects([ProjectList_Previews.previewProjects[0]])
        appData.devices = []
        return appData
    }()
    
    static var previews: some View {
        Group {
            NavigationView {
                DataAcquisitionView()
                    .environmentObject(noDevicesAppData)
            }
            .setBackgroundColor(Assets.blue)
            .setSingleColumnNavigationViewStyle()
            
            NavigationView {
                DataAcquisitionView()
                    .environmentObject(ProjectList_Previews.projectsPreviewAppData)
            }
            .setBackgroundColor(Assets.blue)
            .setSingleColumnNavigationViewStyle()
        }
    }
}
#endif
