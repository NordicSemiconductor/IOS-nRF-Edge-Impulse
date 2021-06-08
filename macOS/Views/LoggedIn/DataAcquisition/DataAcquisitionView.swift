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
    
    @ObservedObject internal var viewState = DataAcquisitionViewState()
    
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
                    DataAcquisitionDevicePicker(viewState: viewState)
                    
                    Text("Sample Length")
                    DataAcquisitionViewSampleLengthPicker(viewState: viewState)
                    
                    Text("Frequency")
                    DataAcquisitionFrequencyPicker(viewState: viewState)
                }
                .disabled(viewState.isSampling)
                
                Divider()
                    .padding(.vertical)
                
                Section(header: Text("Progress").bold()) {
                    ProgressView(value: viewState.progress, total: 100.0)
                        .frame(maxWidth: 250)
                    
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
            guard let device = connectedDevices.first else { return }
            viewState.selectedDevice = device
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
