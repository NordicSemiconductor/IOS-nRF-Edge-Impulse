//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 18/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    // MARK: - State
    
    @EnvironmentObject var deviceData: DeviceData
    
    @ObservedObject private var viewState = DataAcquisitionViewState()
    @State private var isSampling = false
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Section(header: Text("Target").bold()) {
                    Picker("Device", selection: $viewState.selectedDevice) {
                        
                        let connectedDevices = deviceData.scanResults
                            .filter { $0.state.isReady }
                        
                        if connectedDevices.count > 0 {
                            ForEach(connectedDevices, id: \.self) { device in
                                Text(device.id.uuidString).tag(device)
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
            let connectedDevices = deviceData.scanResults
                .filter { $0.state.isReady }
            if let device = connectedDevices.first {
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
        appData.loginState = .showingUser(Preview.previewUser, [])
        return appData
    }()
    
    static var previews: some View {
        Group {
            DataAcquisitionView()
                .environmentObject(Self.noProjectsAppData)
            DataAcquisitionView()
                .environmentObject(Preview.projectsPreviewAppData)
        }
    }
}
#endif
