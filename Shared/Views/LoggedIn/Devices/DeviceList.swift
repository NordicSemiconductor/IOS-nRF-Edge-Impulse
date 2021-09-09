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
    
    @State private var showDeleteDeviceAlert = false
    @State private var renameDevice: Device? = nil
    @State private var deleteDevice: Device? = nil
    
    private let logger = Logger(category: "DeviceList")
    
    // MARK: View
    
    var body: some View {
        AlertViewContainer(content: {
            FormIniOSListInMacOS {
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
            // Fix for ToolbarItem glitching the Project Menu on iOS.
            ToolbarItem(placement: .destructiveAction) {
                refreshToolbarButton()
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
            UnregisteredDeviceView(s.scanResult, isConnecting: s.state == .connecting)
                .onTapGesture {
                    guard s.scanResult.isConnectable else { return }
                    deviceData.tryToConnect(scanResult: s.scanResult)
                }
        }
    }
    
    // MARK: Registered Devices
    @ViewBuilder
    private func buildRegisteredDevicesList() -> some View {
        DeviceSection(data: deviceData.registeredDevices) { wrapper in
            NavigationLink(destination: DeviceDetails(device: wrapper.device)) {
                RegisteredDeviceView(wrapper.device, connectionState: wrapper.state)
            }
            .contextMenu {
                deviceContextMenu(wrapper)
            }
        }
    }
    
    @ViewBuilder
    private func deviceContextMenu(_ deviceWrapper: DeviceData.DeviceWrapper) -> some View {
        
        if case .readyToConnect = deviceWrapper.state {
            Button {
                deviceData.tryToConnect(device: deviceWrapper.device)
            } label: {
                Label("Connect", systemImage: "app.connected.to.app.below.fill")
            }
        } else if case .connected = deviceWrapper.state {
            Button() {
                deviceData.disconnect(device: deviceWrapper.device)
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
            renameDevice = deviceWrapper.device
        }) {
            Label("Rename", systemImage: "pencil")
        }
        
        Divider()
        Button {
            deleteDevice = deviceWrapper.device
            showDeleteDeviceAlert = true
        } label: {
            Label("Delete", systemImage: "minus.circle")
        }
    }
    
    private func refreshToolbarButton() -> some View {
        Button(action: deviceData.refresh, label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        })
        .keyboardShortcut(KeyEquivalent("r"), modifiers: [.command])
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
