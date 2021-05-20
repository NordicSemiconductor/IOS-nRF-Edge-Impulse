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
    
    @EnvironmentObject var scannerData: ScannerData
    @EnvironmentObject var appData: AppData
    
    @State private var scannerCancellable: Cancellable? = nil
    
    private let logger = Logger(category: "DeviceList")
    
    // MARK: View
    
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
                        Image(systemName: scannerData.isScanning ? "stop.fill" : "play.fill")
                    })
                    .keyboardShortcut(.space, modifiers: [])
                }
            }
            .onAppear() {
                guard !Constant.isRunningInPreviewMode else { return }
                scannerData.turnOnBluetoothRadio()
            }
            .onDisappear() {
                scannerCancellable?.cancel()
            }
            .accentColor(.white)
    }
    
    @ViewBuilder
    private func buildRootView() -> some View {
        if scannerData.scanResults.isEmpty {
            VStack(spacing: 8) {
                if scannerData.isScanning {
                    ProgressView()
                        .foregroundColor(.accentColor)
                        .progressViewStyle(CircularProgressViewStyle())
                    
                    Text("Can't Find What you're Looking For? Check your Settings.")
                        .font(.caption)
                } else {
                    Text("No Scanned Devices")
                        .font(.headline)
                        .bold()
                }
            }
        } else {
            buildDeviceList()
        }
    }
}

// MARK: - List

private extension DeviceList {
    
    @ViewBuilder
    private func buildDeviceList() -> some View {
        List {
            Section(header: Text("Devices")) {
                
            }
            Section(header: Text("Scan Results")) {
                let devices = ListSection.notConnectedDevices.devices(from: scannerData)
                if devices.hasItems {
                    ForEach(devices) { device in
                        
                        DeviceRow(device, connectionType: .scanResult)
                            .onTapGesture {
                                appData.selectedProject
                                    .flatMap { appData.projectDevelopmentKeys[$0]?.apiKey }
                                    .flatMap { scannerData[device].connect(apiKey: $0) }
                                self.logger.info("Device ID: \(device.id))")
                                
                                // TODO: change row state
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
        
        func devices(from deviceData: ScannerData) -> [Device] {
            switch self {
            case .connectedDevices:
                return deviceData.allConnectedAndReadyToUseDevices()
            case .notConnectedDevices:
                return deviceData.allOtherDevices()
            }
        }
    }
}

// MARK: - Private API

private extension DeviceList {
    
    func toggleScanner() {
        scannerData.toggle()
    }
    
    func refreshScanner() {
        scannerData.scanResults = scannerData.scanResults.filter {
            $0.state != .notConnected
        }
        guard !scannerData.isScanning else { return }
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
