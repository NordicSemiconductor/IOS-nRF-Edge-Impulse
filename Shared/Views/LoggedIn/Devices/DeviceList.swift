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
    
    @State private var renameDevice: Device? = nil
    
    @State private var showDeleteDeviceAlert = false
    @State private var deleteDevice: Device? = nil
    
    @State private var selectedDeviceId: String? = nil
    
    private let logger = Logger(category: "DeviceList")
    
    // MARK: View
    
    var body: some View {
        AlertViewContainer(content: {
            ScrollView {
                buildRegisteredDevicesList()
                buildScanResultsList(scanResult: deviceData.scanResults.filter { $0.state != .connected && !$0.availableViaRegisteredDevices })
                
                #if os(macOS)
                MacAddressView()
                #endif
            }
        }, alertView: { device in
            RenameDeviceView($renameDevice, oldName: device.name)
        }, isShowing: $renameDevice)
        .alert(isPresented: $showDeleteDeviceAlert) {
            Alert(title: Text("Delete Device"),
                  message: Text("Are you sure you want to delete this Device?"),
                  primaryButton: .destructive(Text("Yes"), action: confirmDeleteDevice),
                  secondaryButton: .default(Text("Cancel"), action: dismissDeleteDevice))
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: refreshScanner, label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                })
                .keyboardShortcut(KeyEquivalent("r"), modifiers: [.command])
            }
        }
        .accentColor(.white)
        .background(Color.formBackground)
    }
}

// MARK: - List

private extension DeviceList {
    // MARK: Scan results
    @ViewBuilder
    private func buildScanResultsList(scanResult: [DeviceData.ScanResultWrapper]) -> some View {
        
        DeviceSection(title: "Add Device", data: scanResult) { s in
            UnregisteredDeviceRow(s.scanResult, isConnecting: s.state == .connecting)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard s.scanResult.isConnectable else { return }
                    deviceData.tryToConnect(scanResult: s.scanResult)
                }
        }
    }
    
    // MARK: Registered Devices
    @ViewBuilder
    private func buildRegisteredDevicesList() -> some View {
        DeviceSection(title: "Devices", data: deviceData.registeredDevices) { d in
            RegisteredDeviceRow(device: d.device, state: d.state, selection: $selectedDeviceId)
                .contextMenu {
                    deviceContextMenu(device: d.device, state: d.state)
                }
        }
    }
    
    @ViewBuilder
    private func deviceContextMenu(device: Device, state: DeviceData.DeviceWrapper.State) -> some View {
        
        if case .readyToConnect = state {
            Button {
                deviceData.tryToConnect(device: device)
            } label: {
                Label("Connect", systemImage: "app.connected.to.app.below.fill")
            }
        } else if case .connected = state {
            Button() {
                deviceData.disconnect(device: device)
            } label: {
                Label {
                    Text("Disconnect")
                } icon: {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(Color.blue)
                }
            }
            .foregroundColor(Assets.red.color)
        }
        
        Button(action: {
            renameDevice = device
        }) {
            Label("Rename", systemImage: "pencil")
        }
        Button {
            selectedDeviceId = device.deviceId
        } label: {
            Label("Get info", systemImage: "info.circle")
        }
        
        Divider()
        Button {
            deleteDevice = device
            showDeleteDeviceAlert = true
        } label: {
            Label("Delete", systemImage: "minus.circle")
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
        deviceData.refresh()
    }
    
    func confirmDeleteDevice() {
        showDeleteDeviceAlert = false
        guard let device = deleteDevice else { return }
        
        deviceData.tryToDelete(device: device)
        deleteDevice = nil
    }
    
    func dismissDeleteDevice() {
        showDeleteDeviceAlert = false
        deleteDevice = nil
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
                    .environmentObject(Preview.mockRegisteredDevices)
                    .previewDevice("iPhone 12")
                    .previewDisplayName("Registered Devices")
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
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
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
