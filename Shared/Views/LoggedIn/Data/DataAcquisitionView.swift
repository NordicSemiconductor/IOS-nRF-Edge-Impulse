//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: - State
    
    @ObservedObject var viewState = DataAcquisitionViewState()
    
    // MARK: - @viewBuilder
    
    var body: some View {
        Form {
            Section(header: Text("Project")) {
                if appData.projects.count > 0 {
                    Picker("Selected", selection: $viewState.selectedProject) {
                        ForEach(appData.projects, id: \.self) { project in
                            Text(project.name).tag(project as Project?)
                        }
                    }
                    .setAsComboBoxStyle()
                } else {
                    Text("No Projects for this User.")
                        .foregroundColor(Assets.middleGrey.color)
                }
            }
            
            Section(header: Text("Data Type")) {
                Picker("Type", selection: $viewState.selectedDataType) {
                    ForEach(Sample.DataType.allCases, id: \.self) { dataType in
                        Text(dataType.rawValue).tag(dataType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
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
            
            Section(header: Text("Label")) {
                TextField("Label", text: $viewState.label)
            }

            Section(header: Text("Sensor")) {
                Picker("Type", selection: $viewState.selectedSensor) {
                    ForEach(Sample.Sensor.allCases, id: \.self) { sensor in
                        Text(sensor.rawValue).tag(sensor)
                    }
                }
                .setAsComboBoxStyle()
            }
            
            Section(header: Text("Sample Length")) {
                if viewState.canSelectSampleLengthAndFrequency {
                    Stepper(value: $viewState.sampleLength, in: 0...100000) {
                        Text("\(viewState.sampleLength, specifier: "%d") ms")
                    }
                } else {
                    Text("Unavailable for \(Sample.Sensor.Camera.rawValue) Sensor")
                        .foregroundColor(Assets.middleGrey.color)
                }
            }
            
            Section(header: Text("Frequency")) {
                if viewState.canSelectSampleLengthAndFrequency {
                    Picker("Value", selection: $viewState.selectedFrequency) {
                        ForEach(Sample.Frequency.allCases, id: \.self) { frequency in
                            Text(frequency.description).tag(frequency)
                        }
                    }
                    .setAsComboBoxStyle()
                } else {
                    Text("Unavailable for \(Sample.Sensor.Camera.rawValue) Sensor")
                        .foregroundColor(Assets.middleGrey.color)
                }
            }
            
            Button("Start Sampling") {
                startSampling()
            }
            .centerTextInsideForm()
            .disabled(viewState.canStartSampling)
            .accentColor(viewState.canStartSampling ? Assets.middleGrey.color : Assets.red.color)
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
        .previewDevice("iPhone 12 mini")
    }
}
#endif
