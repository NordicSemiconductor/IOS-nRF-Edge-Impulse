//
//  DataAcquisitionFormView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 19/8/21.
//

import SwiftUI
import Introspect

struct DataAcquisitionFormView: View {
    
    @EnvironmentObject var viewState: DataAcquisitionViewState
    
    @State private var keyboardShownOnce = false
    
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
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DataAcquisitionFormView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            DataAcquisitionFormView()
                .environmentObject(DataAcquisitionViewState())
                .environmentObject(Preview.projectsPreviewAppData)
                .environmentObject(Preview.mockScannerData)
        }
        .previewDevice("iPhone 12 mini")
    }
}
#endif
