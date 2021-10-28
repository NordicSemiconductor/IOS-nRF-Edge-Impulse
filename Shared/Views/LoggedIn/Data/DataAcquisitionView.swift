//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var dataAcquisitionViewState: DataAcquisitionViewState
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    @State private var keyboardShownOnce = false
    
    // MARK: - @viewBuilder
    
    var body: some View {
        FormIniOSListInMacOS {
            Section(header: Text("Category")) {
                Picker("Selected", selection: $appData.selectedCategory) {
                    ForEach(DataSample.Category.allCases) { dataType in
                        Text(dataType.rawValue.uppercasingFirst)
                            .tag(dataType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(dataAcquisitionViewState.isSampling)
            }
            
            Section(header: Text("Device")) {
                ConnectedDevicePicker($dataAcquisitionViewState.selectedDevice)
                    .disabled($dataAcquisitionViewState.isSampling.wrappedValue)
            }
            
            Section(header: Text("Label")) {
                TextField("Label", text: $dataAcquisitionViewState.label)
                    .disabled(dataAcquisitionViewState.isSampling)
                    .introspectTextField { textField in
                        guard !keyboardShownOnce,
                              !dataAcquisitionViewState.isSampling,
                              dataAcquisitionViewState.label.isEmpty else { return }
                        keyboardShownOnce = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [textField] in
                            textField.becomeFirstResponder()
                        }
                    }
            }

            Section(header: Text("Sensor")) {
                DataAcquisitionSensorPicker(viewState: dataAcquisitionViewState)
            }
            
            Section(header: Text("Sample Length")) {
                DataAcquisitionViewSampleLengthPicker(viewState: dataAcquisitionViewState)
            }
            .disabled(dataAcquisitionViewState.isSampling)
            
            Section(header: Text("Frequency")) {
                DataAcquisitionFrequencyPicker(viewState: dataAcquisitionViewState)
            }
            .disabled(dataAcquisitionViewState.isSampling)
            
            #if os(macOS)
            Divider()
                .padding(.horizontal)
            #endif
            
            Section(header: Text("Progress").bold()) {
                ReusableProgressView(progress: $dataAcquisitionViewState.progress, isIndeterminate: $dataAcquisitionViewState.indeterminateProgress, statusText: $dataAcquisitionViewState.progressString, statusColor: $dataAcquisitionViewState.progressColor, buttonText: "Start Sampling", buttonEnabled: $dataAcquisitionViewState.samplingButtonEnable, buttonAction: startSampling)
            }
        }
        .setTitle("Record New Data")
        .onAppear(perform: setInitialSelectedDevice)
        .onReceive(dataAcquisitionViewState.countdownTimer, perform: dataAcquisitionViewState.onSampleTimerTick(_:))
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
