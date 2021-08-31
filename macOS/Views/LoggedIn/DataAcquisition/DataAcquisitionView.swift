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
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            Section(header: Text("Target").bold()) {
                ConnectedDevicePicker($appData.dataAquisitionViewState.selectedDevice)
                    .disabled(appData.dataAquisitionViewState.isSampling)
            }
            
            Divider()
                .padding(.vertical)
            
            Section(header: Text("Data Collection").bold()) {
                MultiColumnView {
                    Text("Sample Name")
                    TextField("Label", text: $appData.dataAquisitionViewState.label)
                    
                    Text("Category")
                    Picker(selection: $appData.dataAquisitionViewState.selectedDataType, label: EmptyView()) {
                        ForEach(DataSample.Category.allCases, id: \.self) { dataType in
                            Text(dataType.rawValue.uppercasingFirst).tag(dataType)
                        }
                    }.pickerStyle(RadioGroupPickerStyle())
                    .horizontalRadioGroupLayout()
                    .padding(.vertical, 6)
                    
                    Text("Sensor")
                    DataAcquisitionDevicePicker(viewState: appData.dataAquisitionViewState)
                    
                    Text("Sample Length")
                    DataAcquisitionViewSampleLengthPicker(viewState: appData.dataAquisitionViewState)
                    
                    Text("Frequency")
                    DataAcquisitionFrequencyPicker(viewState: appData.dataAquisitionViewState)
                }
                .disabled(appData.dataAquisitionViewState.isSampling)
                
                Divider()
                    .padding(.vertical)
                
                Section(header: Text("Progress").bold()) {
                    ReusableProgressView(progress: $appData.dataAquisitionViewState.progress, isIndeterminate: $appData.dataAquisitionViewState.indeterminateProgress, statusText: $appData.dataAquisitionViewState.progressString, statusColor: $appData.dataAquisitionViewState.progressColor, buttonText: "Start Sampling", buttonEnabled: $appData.dataAquisitionViewState.samplingButtonEnable, buttonAction: startSampling)
                }
            }
        }
        .setTitle("New Sample")
        .padding(16)
        .onAppear(perform: setInitialSelectedDevice)
        .onReceive(appData.dataAquisitionViewState.countdownTimer, perform: onSampleTimerTick(_:))
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
