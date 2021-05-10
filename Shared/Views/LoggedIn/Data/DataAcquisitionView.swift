//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var scannerData: ScannerData
    
    // MARK: - State
    
    @ObservedObject var viewState = DataAcquisitionViewState()
    
    // MARK: - @viewBuilder
    
    var body: some View {
        Form {
            Section(header: Text("Category")) {
                Picker("Selected", selection: $viewState.selectedDataType) {
                    ForEach(DataSample.Category.userVisible) { dataType in
                        Text(dataType.rawValue.uppercasingFirst)
                            .tag(dataType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(viewState.isSampling)
            }
            
            Section(header: Text("Device")) {
                let connectedDevices = scannerData.allConnectedAndReadyToUseDevices()
                if connectedDevices.hasItems {
                    Picker("Selected", selection: $viewState.selectedDevice) {
                        ForEach(connectedDevices, id: \.self) { device in
                            Text(device.name).tag(device)
                        }
                    }
                    .setAsComboBoxStyle()
                    .disabled(viewState.isSampling)
                } else {
                    Text("No Connected Devices")
                        .foregroundColor(Assets.middleGrey.color)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Section(header: Text("Label")) {
                TextField("Label", text: $viewState.label)
                    .disabled(viewState.isSampling)
            }

            Section(header: Text("Sensor")) {
                Picker("Type", selection: $viewState.selectedSensor) {
                    ForEach(NewDataSample.Sensor.allCases) { sensor in
                        Text(sensor.rawValue)
                            .tag(sensor)
                    }
                }
                .setAsComboBoxStyle()
                .disabled(viewState.isSampling)
            }
            
            Section(header: Text("Sample Length")) {
                if viewState.canSelectSampleLengthAndFrequency {
                    Stepper(value: $viewState.sampleLength, in: 0...100000, step: 10) {
                        Text("\(viewState.sampleLength, specifier: "%.0f") ms")
                    }
                    .disabled(viewState.isSampling)
                } else {
                    Text("Unavailable for \(NewDataSample.Sensor.Camera.rawValue) Sensor")
                        .foregroundColor(Assets.middleGrey.color)
                }
            }
            
            Section(header: Text("Frequency")) {
                if viewState.canSelectSampleLengthAndFrequency {
                    Picker("Value", selection: $viewState.selectedFrequency) {
                        ForEach(NewDataSample.Frequency.allCases) { frequency in
                            Text(frequency.description)
                                .tag(frequency)
                        }
                    }
                    .setAsComboBoxStyle()
                    .disabled(viewState.isSampling)
                } else {
                    Text("Unavailable for \(NewDataSample.Sensor.Camera.rawValue) Sensor")
                        .foregroundColor(Assets.middleGrey.color)
                }
            }
            
            Button("Start Sampling", action: startSampling)
                .centerTextInsideForm()
                .disabled(!viewState.canStartSampling || viewState.isSampling)
                .accentColor(viewState.canStartSampling ? Assets.red.color : Assets.middleGrey.color)
        }
        .setTitle("New Sample")
        .onAppear() {
            guard let device = scannerData.allConnectedAndReadyToUseDevices().first else {
                return
            }
            viewState.selectedDevice = device
        }
    }
}

private extension DataAcquisitionView {
    
    func startSampling() {
        scannerData.startSampling(viewState)
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
                    .environmentObject(Preview.noDevicesScannerData)
            }
            
            NavigationView {
                DataAcquisitionView()
                    .environmentObject(Preview.projectsPreviewAppData)
                    .environmentObject(Preview.mockScannerData)
            }
            .setBackgroundColor(.blue)
        }
        .previewDevice("iPhone 12 mini")
    }
}
#endif
