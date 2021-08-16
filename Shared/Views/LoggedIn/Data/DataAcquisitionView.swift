//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/3/21.
//

import SwiftUI
import Introspect

struct DataAcquisitionView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    @ObservedObject internal var viewState = DataAcquisitionViewState()
    @State private var keyboardShownOnce = false
    
    // MARK: - @viewBuilder
    
    var body: some View {
        Form {
            Section(header: Text("Category")) {
                Picker("Selected", selection: $viewState.selectedDataType) {
                    ForEach(DataSample.Category.allCases) { dataType in
                        Text(dataType.rawValue.uppercasingFirst)
                            .tag(dataType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(viewState.isSampling)
            }
            
            Section(header: Text("Device")) {
                ConnectedDevicePicker($viewState.selectedDevice)
                    .disabled(viewState.isSampling)
            }
            
            Section(header: Text("Label")) {
                TextField("Label", text: $viewState.label)
                    .disabled(viewState.isSampling)
                    .introspectTextField { textField in
                        guard !keyboardShownOnce, viewState.label.isEmpty else { return }
                        keyboardShownOnce = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [textField] in
                            textField.becomeFirstResponder()
                        }
                    }
            }

            Section(header: Text("Sensor")) {
                DataAcquisitionDevicePicker(viewState: viewState)
            }
            .disabled(viewState.isSampling)
            
            Section(header: Text("Sample Length")) {
                DataAcquisitionViewSampleLengthPicker(viewState: viewState)
            }
            .disabled(viewState.isSampling)
            
            Section(header: Text("Frequency")) {
                DataAcquisitionFrequencyPicker(viewState: viewState)
            }
            .disabled(viewState.isSampling)
            
            Section(header: Text("Progress")) {
                ProgressView(value: viewState.progress, total: 100.0)
                
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
        .setTitle("New Sample")
        .onAppear(perform: setInitialSelectedDevice)
        .onReceive(viewState.countdownTimer, perform: onSampleTimerTick(_:))
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
