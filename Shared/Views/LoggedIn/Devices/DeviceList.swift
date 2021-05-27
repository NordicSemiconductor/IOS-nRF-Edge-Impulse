//
//  DeviceList.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI
import Combine

struct DeviceList: View {
    
    // MARK: Properties
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var scannerData: ScannerData
    
    @State private var scannerCancellable: Cancellable? = nil
    
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
            ForEach(ListSection.allCases) { listSection in
                Section(header: Text(listSection.string).bold()) {
                    let devices = listSection.devices(from: scannerData)
                    if devices.hasItems {
                        ForEach(devices) { device in
                            #if os(OSX)
                            NavigationLink(destination: DeviceDetails(device: device)) {
                                DeviceRow(device)
                            }
                            #else
                            NavigationLink(destination: DeviceDetails(device: device), isActive: $appData.isShowingDetailsView) {
                                DeviceRow(device)
                            }
                            .isDetailLink(false)
                            #endif
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
    }
    
    enum ListSection: Int, Identifiable, CaseIterable {
        case connectedDevices, notConnectedDevices
        
        var id: RawValue { rawValue }
        
        var string: String {
            switch self {
            case .connectedDevices:
                return "Connected Devices"
            case .notConnectedDevices:
                return "Not Connected Devices"
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
                .environmentObject(Preview.projectsPreviewAppData)
                .environmentObject(Preview.mockScannerData)
        }
        #elseif os(iOS)
        Group {
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .environmentObject(Preview.projectsPreviewAppData)
                    .environmentObject(Preview.noDevicesScannerData)
                    .previewDevice("iPhone 12 mini")
            }
            .setBackgroundColor(Assets.blue)
            .setSingleColumnNavigationViewStyle()
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .environmentObject(Preview.projectsPreviewAppData)
                    .environmentObject(Preview.isScanningButNoDevicesScannerData)
                    .previewDevice("iPhone 12 mini")
            }
            .setBackgroundColor(Assets.blue)
            .setSingleColumnNavigationViewStyle()
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .preferredColorScheme(.dark)
                    .environmentObject(Preview.projectsPreviewAppData)
                    .environmentObject(Preview.mockScannerData)
                    .previewDevice("iPad Pro (12.9-inch) (4th generation)")
            }
            .setBackgroundColor(Assets.blue)
            .setSingleColumnNavigationViewStyle()
        }
        #endif
    }
}
#endif
