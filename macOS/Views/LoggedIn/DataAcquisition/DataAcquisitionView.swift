//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 18/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    // MARK: - State
    
    @EnvironmentObject var scannerData: ScannerData
    
    @ObservedObject private var viewState = DataAcquisitionViewState()
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            Section(header: Text("Target").bold()) {
                MultiColumnView {
                    Text("Connected Device")
                    Picker(selection: $viewState.selectedDevice, label: EmptyView()) {
                        let connectedDevices = scannerData.allConnectedAndReadyToUseDevices()
                        if connectedDevices.hasItems {
                            ForEach(connectedDevices) { device in
                                Text(device.name).tag(device)
                            }
                        } else {
                            Text("--").tag(Constant.unselectedDevice)
                        }
                    }
                    .disabled(viewState.isSampling)
                }
            }
            
            Divider()
            
            Section(header: Text("Data Collection").bold()) {
                MultiColumnView {
                    Text("Sample Name")
                    TextField("Label", text: $viewState.label)
                    
                    Text("Sample Length")
                    if viewState.canSelectSampleLengthAndFrequency {
                        HStack {
                            Slider(value: $viewState.sampleLength, in: 0...100000)
                            Text("\(viewState.sampleLength, specifier: "%2.f") ms")
                        }
                    } else {
                        Text("Unavailable")
                            .foregroundColor(Assets.middleGrey.color)
                    }
                    
                    Text("Category")
                    Picker(selection: $viewState.selectedDataType, label: EmptyView()) {
                        ForEach(DataSample.Category.userVisible, id: \.self) { dataType in
                            Text(dataType.rawValue).tag(dataType)
                        }
                    }.pickerStyle(RadioGroupPickerStyle())
                    
                    Text("Sensor")
                    Picker(selection: $viewState.selectedSensor, label: EmptyView()) {
                        ForEach(NewDataSample.Sensor.allCases, id: \.self) { sensor in
                            Text(sensor.rawValue).tag(sensor)
                        }
                    }
                    
                    Text("Frequency")
                    if viewState.canSelectSampleLengthAndFrequency {
                        Picker(selection: $viewState.selectedFrequency, label: EmptyView()) {
                            ForEach(NewDataSample.Frequency.allCases, id: \.self) { frequency in
                                Text(frequency.description).tag(frequency)
                            }
                        }
                    } else {
                        Text("Unavailable")
                            .foregroundColor(Assets.middleGrey.color)
                    }
                }
                .disabled(viewState.isSampling)
            }
        }
        .setTitle("New Sample")
        .padding(16)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: startSampling, label: {
                    Image(systemName: viewState.isSampling ? "stop.fill" : "play.fill")
                }).disabled(!viewState.canStartSampling)
            }
        }
        .onAppear {
            let connectedDevices = scannerData.allConnectedAndReadyToUseDevices()
            if let device = connectedDevices.first {
                viewState.selectedDevice = device
            }
        }
    }
}

// MARK: - startSampling()

extension DataAcquisitionView {
    
    func startSampling() {
        scannerData.startSampling(viewState)
    }
}

// MARK: - Preview

#if DEBUG
struct DataAcquisitionView_Previews: PreviewProvider {
    
    static let noProjectsAppData: AppData = {
        let appData = AppData()
        appData.loginState = .complete(Preview.previewUser, [])
        return appData
    }()
    
    static var previews: some View {
        Group {
            DataAcquisitionView()
                .environmentObject(Self.noProjectsAppData)
                .environmentObject(Preview.noDevicesScannerData)
            DataAcquisitionView()
                .environmentObject(Preview.projectsPreviewAppData)
                .environmentObject(Preview.mockScannerData)
        }
    }
}
#endif
