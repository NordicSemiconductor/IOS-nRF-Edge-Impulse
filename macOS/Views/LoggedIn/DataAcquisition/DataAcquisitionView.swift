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
    
    @State private var selectedProject: Project?
    @State private var label = ""
    @State private var selectedDevice: Device?
    @State private var selectedDataType = Sample.DataType.Test
    @State private var selectedSensor = Sensor.Accelerometer
    @State private var sampleLength = 10000.0
    @State private var selectedFrequency = Frequency._11000Hz
    
    var sampleLengthAndFrequencyEnabled: Bool {
        selectedSensor != .Camera
    }
    
    var startSamplingDisabled: Bool {
        return selectedProject == Project.Sample
            || label.count < 1
            || appData.devices.isEmpty
    }
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Section(header: Text("Project").bold()) {
                    Picker("Selected", selection: $selectedProject) {
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
                    Picker("Device", selection: $selectedDevice) {
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
                        TextField("Label", text: $label)
                    }
                    
                    Picker("Data Type", selection: $selectedDataType) {
                        ForEach(Sample.DataType.allCases, id: \.self) { dataType in
                            Text(dataType.rawValue).tag(dataType)
                        }
                        .frame(width: 70)
                    }.pickerStyle(RadioGroupPickerStyle())
                    
                    Picker("Sensor", selection: $selectedSensor) {
                        ForEach(Sensor.allCases, id: \.self) { sensor in
                            Text(sensor.rawValue).tag(sensor)
                        }
                    }
                    
                    HStack {
                        Text("Sample Length")
                        if sampleLengthAndFrequencyEnabled {
                            Slider(value: $sampleLength, in: 0...100000)
                            Text("\(sampleLength, specifier: "%2.f") ms")
                        } else {
                            Text("Unavailable")
                                .foregroundColor(Assets.middleGrey.color)
                        }
                    }
                    
                    HStack {
                        Text("Frequency")
                        if sampleLengthAndFrequencyEnabled {
                            Picker("Value", selection: $selectedFrequency) {
                                ForEach(Frequency.allCases, id: \.self) { frequency in
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
                .disabled(startSamplingDisabled)
                .accentColor(startSamplingDisabled ? Assets.middleGrey.color : Assets.red.color)
            }
            .padding()
        }
        .frame(width: 320)
        .onAppear {
            selectedProject = appData.projects.first ?? Project.Sample
            selectedDevice = appData.devices.first ?? Device.Dummy
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
