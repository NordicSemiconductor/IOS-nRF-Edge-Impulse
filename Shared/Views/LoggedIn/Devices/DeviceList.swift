//
//  DeviceList.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI
import Combine

struct DeviceList: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    @EnvironmentObject var preferencesData: PreferencesData
    
    @State private var scannerCancellable: Cancellable? = nil
    
    var body: some View {
        
        buildRootView()
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: refreshScanner, label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                })
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: toggleScanner, label: {
                    Image(systemName: deviceData.isScanning ? "stop.fill" : "play.fill")
                })
            }
        }
        .onDisappear() {
            scannerCancellable?.cancel()
        }
        .accentColor(.white)
    }
    
    @ViewBuilder
    private func buildRootView() -> some View {
        if deviceData.scanResults.isEmpty {
            Text("No Scanned Devices")
                .font(.headline)
                .bold()
        } else {
            buildDeviceList()
        }
    }
    
    @ViewBuilder
    private func buildDeviceList() -> some View {
//        let splitedDevices = appData.allDevices.split(whereSeparator: { $0.state.isReady })
//        
//        let connected = appData.allDevices.filter { $0.state.isReady }
//        let notConnected = appData.allDevices.filter { !$0.state.isReady }
        
        List {
            if !deviceData.scanResults.filter { $0.state.isReady }.isEmpty {
                Section(header: Text("Connected Devices")) {
                    ForEach(deviceData.scanResults.filter { $0.state.isReady }) { device in
                        NavigationLink(destination: DeviceDetails(device: device)) {
                            DeviceRow(device: device)
                        }
                    }
                }
            }
            if !deviceData.scanResults.filter { !$0.state.isReady }.isEmpty {
                Section(header: Text("Not Connected Devices")) {
                    ForEach(deviceData.scanResults.filter { !$0.state.isReady }) { device in
                        NavigationLink(destination: DeviceDetails(device: device)) {
                            DeviceRow(device: device)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Private API

private extension DeviceList {
    
    func toggleScanner() {
        deviceData.toggle(with: preferencesData)
    }
    
    func refreshScanner() {
        deviceData.scanResults.removeAll()
        guard !deviceData.isScanning else { return }
        toggleScanner()
    }
}

// MARK: - Preview

#if DEBUG
struct DeviceList_Previews: PreviewProvider {
    
    static var previews: some View {
        #if os(OSX)
        Group {
            DeviceList()
                .setTitle("Devices")
                .environmentObject(Preview.projectsPreviewAppData)
        }
        #elseif os(iOS)
        Group {
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .environmentObject(Preview.projectsPreviewAppData)
                    .environmentObject(Preview.noDevicesDeviceData)
                    .previewDevice("iPhone 12 mini")
            }
            .setBackgroundColor(Assets.blue)
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .preferredColorScheme(.dark)
                    .environmentObject(Preview.projectsPreviewAppData)
                    .environmentObject(Preview.mockDevicedDeviceData)
                    .previewDevice("iPad Pro (12.9-inch) (4th generation)")
            }
            .setBackgroundColor(Assets.blue)
        }
        #endif
    }
}
#endif
