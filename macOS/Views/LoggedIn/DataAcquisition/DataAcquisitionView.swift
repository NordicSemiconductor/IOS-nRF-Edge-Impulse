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
                .padding(.vertical)
            
            Section(header: Text("Data Collection").bold()) {
                MultiColumnView {
                    Text("Sample Name")
                    TextField("Label", text: $viewState.label)
                    
                    Text("Category")
                    Picker(selection: $viewState.selectedDataType, label: EmptyView()) {
                        ForEach(DataSample.Category.userVisible, id: \.self) { dataType in
                            Text(dataType.rawValue.uppercasingFirst).tag(dataType)
                        }
                    }.pickerStyle(RadioGroupPickerStyle())
                    .horizontalRadioGroupLayout()
                    .padding(.vertical, 6)
                    
                    Text("Sensor")
                    Picker(selection: $viewState.selectedSensor, label: EmptyView()) {
                        ForEach(NewDataSample.Sensor.allCases, id: \.self) { sensor in
                            Text(sensor.rawValue).tag(sensor)
                        }
                    }
                    
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
                
                Divider()
                    .padding(.vertical)
                
                Section(header: Text("Progress").bold()) {
                    ProgressView(value: viewState.progress, total: 100.0)
                        .frame(maxWidth: 250)
                    
                    Text(viewState.progressString)
                        .lineLimit(0)
                        .foregroundColor(.primary)
                        .centerTextInsideForm()
                    
                    Button("Start Sampling", action: startSampling)
                        .centerTextInsideForm()
                        .disabled(!viewState.canStartSampling || viewState.isSampling)
                        .accentColor(viewState.canStartSampling ? Assets.red.color : Assets.middleGrey.color)
                }
            }
        }
        .setTitle("New Sample")
        .padding(16)
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
        viewState.progressString = "Requesting Sample ID..."
        appData.requestNewSampleID(viewState) { response, error in
            guard let response = response else {
                let error: Error! = error
                viewState.isSampling = false
                viewState.progressString = error.localizedDescription
                return
            }
        
            viewState.progressString = "Obtained Sample ID."
            scannerData.startSampling(viewState)
        }
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
