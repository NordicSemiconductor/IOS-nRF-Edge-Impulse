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
    @EnvironmentObject var dataAcquisitionViewState: DataAcquisitionViewState
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            Section(header: Text("Target").bold()) {
                ConnectedDevicePicker($dataAcquisitionViewState.selectedDevice)
                    .disabled($dataAcquisitionViewState.isSampling.wrappedValue)
            }
            
            Divider()
                .padding(.vertical)
            
            Section(header: Text("Data Collection").bold()) {
                MultiColumnView {
                    Text("Sample Name")
                    TextField("Label", text: $dataAcquisitionViewState.label)
                    
                    Text("Category")
                    Picker(selection: $appData.selectedCategory, label: EmptyView()) {
                        ForEach(DataSample.Category.allCases, id: \.self) { dataType in
                            Text(dataType.rawValue.uppercasingFirst).tag(dataType)
                        }
                    }.pickerStyle(RadioGroupPickerStyle())
                    .horizontalRadioGroupLayout()
                    .padding(.vertical, 6)
                    
                    Text("Sensor")
                    DataAcquisitionSensorPicker(viewState: dataAcquisitionViewState)
                    
                    Text("Sample Length")
                    DataAcquisitionViewSampleLengthPicker(viewState: dataAcquisitionViewState)
                    
                    Text("Frequency")
                    DataAcquisitionFrequencyPicker(viewState: dataAcquisitionViewState)
                }
                .disabled(dataAcquisitionViewState.isSampling)
                
                Divider()
                    .padding(.vertical)
                
                Section(header: Text("Progress").bold()) {
                    ReusableProgressView(progress: $dataAcquisitionViewState.progress, isIndeterminate: $dataAcquisitionViewState.indeterminateProgress, statusText: $dataAcquisitionViewState.progressString, statusColor: $dataAcquisitionViewState.progressColor, buttonText: "Start Sampling", buttonEnabled: $dataAcquisitionViewState.samplingButtonEnable, buttonAction: startSampling)
                }
            }
        }
        .setTitle("New Sample")
        .padding(16)
        .onAppear(perform: setInitialSelectedDevice)
        .onReceive(dataAcquisitionViewState.countdownTimer, perform: dataAcquisitionViewState.onSampleTimerTick(_:))
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
