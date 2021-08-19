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
    
    @ObservedObject internal var viewState = DataAcquisitionViewState()
    @State private var keyboardShownOnce = false
    
    // MARK: - @viewBuilder
    
    var body: some View {
        VStack {
            DataAcquisitionFormView()
                .environmentObject(viewState)
            
            Divider()
                .padding(.horizontal)
            
            Form {
                Section(header: Text("Progress")) {
                    ProgressView(value: viewState.progress, total: 100.0)
                    
                    Button("Start Sampling", action: startSampling)
                        .disabled(!viewState.canStartSampling || viewState.isSampling)
                        .accentColor(viewState.canStartSampling ? Assets.red.color : Assets.middleGrey.color)
                }
            }
            .frame(height: 140)
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
