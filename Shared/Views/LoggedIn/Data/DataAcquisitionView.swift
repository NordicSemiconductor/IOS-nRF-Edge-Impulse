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
                switch appData.loginState {
                case .showingUser(_, let projects):
                    Picker("Selected", selection: $viewState.selectedProject) {
                        ForEach(projects) { project in
                            Text(project.name).tag(project as Project?)
                        }
                    }
                    .setAsComboBoxStyle()
                default:
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
                if appData.scanResults.count > 0 {
                    Picker("Selected", selection: $viewState.selectedDevice) {
                        ForEach(appData.scanResults, id: \.self) { device in
                            Text(device.name).tag(device)
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
                    Stepper(value: $viewState.sampleLength, in: 0...100000, step: 10) {
                        Text("\(viewState.sampleLength, specifier: "%.0f") ms")
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
            .disabled(!viewState.canStartSampling)
            .accentColor(viewState.canStartSampling ? Assets.red.color : Assets.middleGrey.color)
        }
    }
}

private extension DataAcquisitionView {
    
    func startSampling() {
        
    }
}

// MARK: - Preview

#if DEBUG
struct DataAcquisitionView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            NavigationView {
                DataAcquisitionView()
                    .environmentObject(Preview.noDevicesAppData)
            }
            
            NavigationView {
                DataAcquisitionView()
                    .environmentObject(Preview.projectsPreviewAppData)
            }
            .setBackgroundColor(.blue)
        }
        .previewDevice("iPhone 12 mini")
    }
}
#endif
