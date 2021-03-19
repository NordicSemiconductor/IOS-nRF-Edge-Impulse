//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 18/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    // MARK: - State
    
    @EnvironmentObject var appData: AppData
    
    @ObservedObject private var viewState = DataAcquisitionViewState()
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Section(header: Text("Project").bold()) {
                    Picker("Selected", selection: $viewState.selectedProject) {
                        if appData.projects.count > 0 {
                            ForEach(appData.projects, id: \.self) { project in
                                Text(project.name)
                                    .tag(project as Project?)
                            }
                        } else {
                            Text("--").tag(Project.Sample as Project?)
                        }
                    }
                }
                
                Divider()
                
                Section(header: Text("Target").bold()) {
                    Picker("Device", selection: $viewState.selectedDevice) {
                        if appData.devices.count > 0 {
                            ForEach(appData.devices, id: \.self) { device in
                                Text(device.id.uuidString).tag(device as Device?)
                            }
                        } else {
                            Text("--").tag(Device.Dummy as Device?)
                        }
                    }
                }
                
                Divider()
                
                Section(header: Text("Data Collection").bold()) {
                    HStack {
                        Text("Sample Name")
                        TextField("Label", text: $viewState.label)
                    }
                    
                    Picker("Data Type", selection: $viewState.selectedDataType) {
                        ForEach(Sample.DataType.allCases, id: \.self) { dataType in
                            Text(dataType.rawValue).tag(dataType)
                        }
                        .frame(width: 70)
                    }.pickerStyle(RadioGroupPickerStyle())
                    
                    Picker("Sensor", selection: $viewState.selectedSensor) {
                        ForEach(Sample.Sensor.allCases, id: \.self) { sensor in
                            Text(sensor.rawValue).tag(sensor)
                        }
                    }
                    
                    HStack {
                        Text("Sample Length")
                        if viewState.canSelectSampleLengthAndFrequency {
                            Slider(value: $viewState.sampleLength, in: 0...100000)
                            Text("\(viewState.sampleLength, specifier: "%2.f") ms")
                        } else {
                            Text("Unavailable")
                                .foregroundColor(Assets.middleGrey.color)
                        }
                    }
                    
                    HStack {
                        Text("Frequency")
                        if viewState.canSelectSampleLengthAndFrequency {
                            Picker("Value", selection: $viewState.selectedFrequency) {
                                ForEach(Sample.Frequency.allCases, id: \.self) { frequency in
                                    Text(frequency.description).tag(frequency)
                                }
                            }
                        } else {
                            Text("Unavailable")
                                .foregroundColor(Assets.middleGrey.color)
                        }
                    }
                }
                
                Divider()
                
                Button("Start Sampling") {
                    startSampling()
                }
                .centerTextInsideForm()
                .disabled(viewState.canStartSampling)
                .accentColor(viewState.canStartSampling ? Assets.middleGrey.color : Assets.red.color)
            }
            .padding()
        }
        .frame(width: 320)
        .onAppear {
            viewState.selectedProject = appData.projects.first ?? Project.Sample
            viewState.selectedDevice = appData.devices.first ?? Device.Dummy
        }
    }
}

// MARK: - startSampling()

extension DataAcquisitionView {
    
    func startSampling() {
        
    }
}

// MARK: - Preview

#if DEBUG
struct DataAcquisitionView_Previews: PreviewProvider {
    
    static let noProjectsAppData: AppData = {
        let appData = AppData()
        appData.projectsViewState = .showingProjects([])
        appData.projects = []
        appData.devices = []
        return appData
    }()
    
    static var previews: some View {
        Group {
            DataAcquisitionView()
                .environmentObject(Self.noProjectsAppData)
            DataAcquisitionView()
                .environmentObject(ProjectList_Previews.projectsPreviewAppData)
        }
    }
}
#endif
