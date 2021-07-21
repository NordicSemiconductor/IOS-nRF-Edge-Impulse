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
    
    @ObservedObject internal var viewState = DataAcquisitionViewState()
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            Section(header: Text("Target").bold()) {
                ConnectedDevicePicker($viewState.selectedDevice)
                    .disabled(viewState.isSampling)
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
        .onAppear(perform: setInitialSelectedDevice)
        .onReceive(viewState.countdownTimer, perform: onSampleTimerTick(_:))
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
