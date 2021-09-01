//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    @State private var keyboardShownOnce = false
    
    // MARK: - @viewBuilder
    
    var body: some View {
        FormIniOSListInMacOS {
            Section(header: Text("Category")) {
                Picker("Selected", selection: $appData.dataAquisitionViewState.selectedDataType) {
                    ForEach(DataSample.Category.allCases) { dataType in
                        Text(dataType.rawValue.uppercasingFirst)
                            .tag(dataType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(appData.dataAquisitionViewState.isSampling)
            }
            
            Section(header: Text("Device")) {
                ConnectedDevicePicker($appData.dataAquisitionViewState.selectedDevice)
                    .disabled($appData.dataAquisitionViewState.isSampling.wrappedValue)
            }
            
            Section(header: Text("Label")) {
                TextField("Label", text: $appData.dataAquisitionViewState.label)
                    .disabled(appData.dataAquisitionViewState.isSampling)
                    .introspectTextField { textField in
                        guard !keyboardShownOnce,
                              !appData.dataAquisitionViewState.isSampling,
                              appData.dataAquisitionViewState.label.isEmpty else { return }
                        keyboardShownOnce = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [textField] in
                            textField.becomeFirstResponder()
                        }
                    }
            }

            Section(header: Text("Sensor")) {
                DataAcquisitionSensorPicker(viewState: appData.dataAquisitionViewState)
            }
            
            Section(header: Text("Sample Length")) {
                DataAcquisitionViewSampleLengthPicker(viewState: appData.dataAquisitionViewState)
            }
            .disabled(appData.dataAquisitionViewState.isSampling)
            
            Section(header: Text("Frequency")) {
                DataAcquisitionFrequencyPicker(viewState: appData.dataAquisitionViewState)
            }
            .disabled(appData.dataAquisitionViewState.isSampling)
            
            #if os(macOS)
            Divider()
                .padding(.horizontal)
            #endif
            
            Section(header: Text("Progress").bold()) {
                ReusableProgressView(progress: $appData.dataAquisitionViewState.progress, isIndeterminate: $appData.dataAquisitionViewState.indeterminateProgress, statusText: $appData.dataAquisitionViewState.progressString, statusColor: $appData.dataAquisitionViewState.progressColor, buttonText: "Start Sampling", buttonEnabled: $appData.dataAquisitionViewState.samplingButtonEnable, buttonAction: startSampling)
            }
        }
        .setTitle("Record New Data")
        .onAppear(perform: setInitialSelectedDevice)
        .onReceive(appData.dataAquisitionViewState.countdownTimer, perform: onSampleTimerTick(_:))
        .frame(minWidth: .minTabWidth)
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
