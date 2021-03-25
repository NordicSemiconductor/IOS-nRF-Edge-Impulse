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
    @State private var isSampling = false
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Section(header: Text("Project").bold()) {
                    Picker("Selected", selection: $viewState.selectedProject) {
                        if appData.projects.count > 0 {
                            ForEach(appData.projects, id: \.self) { project in
                                Text(project.name).tag(project as Project?)
                            }
                        } else {
                            Text("--").tag(Constant.unselectedProject as Project?)
                        }
                    }
                }
                
                Divider()
                
                Section(header: Text("Target").bold()) {
                    Picker("Device", selection: $viewState.selectedDevice) {
                        if appData.devices.count > 0 {
                            ForEach(appData.devices, id: \.self) { device in
                                Text(device.name).tag(device)
                            }
                        } else {
                            Text("--").tag(Constant.unselectedDevice)
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
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: startSampling, label: {
                    Image(systemName: isSampling ? "stop.fill" : "play.fill")
                }).disabled(!viewState.canStartSampling)
            }
        }
        .frame(width: 320)
        .onAppear {
            if let project = appData.projects.first {
                viewState.selectedProject = project
            }
            if let device = appData.devices.first {
                viewState.selectedDevice = device
            }
        }
    }
}

// MARK: - startSampling()

extension DataAcquisitionView {
    
    func startSampling() {
        isSampling.toggle()
    }
}

// MARK: - Preview

#if DEBUG
struct DataAcquisitionView_Previews: PreviewProvider {
    
    static let noProjectsAppData: AppData = {
        let appData = AppData()
        appData.dashboardViewState = .showingUser(ProjectList_Previews.previewUser, [])
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
