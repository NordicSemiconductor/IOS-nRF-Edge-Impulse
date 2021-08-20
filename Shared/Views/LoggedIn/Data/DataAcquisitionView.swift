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
    
    @StateObject internal var viewState = DataAcquisitionViewState()
    @State private var keyboardShownOnce = false
    
    // MARK: - @viewBuilder
    
    var body: some View {
        VStack {
            DataAcquisitionFormView()
                .environmentObject(viewState)
            
            Divider()
                .padding(.horizontal)
            
            Section(header: Text("Progress").bold()) {
                ReusableProgressView(progress: $viewState.progress, isIndeterminate: $viewState.indeterminateProgress, statusText: $viewState.progressString, statusColor: $viewState.progressColor, buttonText: "Start Sampling", buttonEnabled: $viewState.samplingButtonEnable, buttonAction: startSampling)
            }
        }
        .setTitle("Record New Data")
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
