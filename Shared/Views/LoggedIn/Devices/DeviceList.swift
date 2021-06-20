//
//  DeviceList.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI
import Combine
import os

struct DeviceList: View {
    
    // MARK: Properties
    
    @EnvironmentObject var deviceData: DeviceData
    @EnvironmentObject var appData: AppData
    
    @State private var scannerCancellable: Cancellable? = nil
    
    private let logger = Logger(category: "DeviceList")
    
    // MARK: View
    
    var body: some View {
        List() {
            buildRegisteredDevicesList(devices: deviceData.registeredDevices)
            buildScanResultsList(scanResult: deviceData.scanResults)
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: refreshScanner, label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                })
            }
        }
        .onDisappear() {
            scannerCancellable?.cancel()
        }
        .accentColor(.white)
    }
}

// MARK: - List

private extension DeviceList {
    
    @ViewBuilder
    private func buildScanResultsList(scanResult: [Device]) -> some View {
        Section(header: Text("Scan Results")) {
            if scanResult.hasItems {
                ForEach(scanResult) { d in
                    DeviceRow(d)
                        .onTapGesture {
                            deviceData.tryToConnect(scanResult: d)
                        }
                }
            } else {
                Text("No Devices")
                    .font(.callout)
                    .foregroundColor(Assets.middleGrey.color)
                    .centerTextInsideForm()
            }
        }
    }
    
    @ViewBuilder
    private func buildRegisteredDevicesList(devices: [RegisteredDevice]) -> some View {
        Section(header: Text("Registered Devices1")) {
            if devices.hasItems {
                ForEach(devices) { d in
                    RegisteredDeviceView(device: d, expanded: false)
                }
            } else {
                Text("No Devices")
                    .font(.callout)
                    .foregroundColor(Assets.middleGrey.color)
                    .centerTextInsideForm()
            }
        }
    }
    
    enum ListSection: Int, Identifiable, CaseIterable {
        case connectedDevices, notConnectedDevices
        
        var id: RawValue { rawValue }
        
        var string: String {
            switch self {
            case .connectedDevices:
                return "Devices"
            case .notConnectedDevices:
                return "Scanner"
            }
        }
    }
}

// MARK: - Private API

private extension DeviceList {
    
    func toggleScanner() {
        deviceData.scanner.toggle()
    }
    
    func refreshScanner() {
//        scannerData.scanResults = scannerData.scanResults.filter {
//            $0.state != .notConnected
//        }
//        guard !deviceData.scanner.isScunning else { return }
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
                .environmentObject(Preview.mockScannerData)
        }
        #elseif os(iOS)
        Group {
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .environmentObject(Preview.noDevicesScannerData)
                    .previewDevice("iPhone 12 mini")
            }
            .setBackgroundColor(Assets.blue)
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .environmentObject(Preview.isScanningButNoDevicesScannerData)
                    .previewDevice("iPhone 12 mini")
            }
            .setBackgroundColor(Assets.blue)
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .preferredColorScheme(.dark)
                    .environmentObject(Preview.mockScannerData)
                    .previewDevice("iPad Pro (12.9-inch) (4th generation)")
            }
            .setBackgroundColor(Assets.blue)
        }
        #endif
    }
}
#endif
