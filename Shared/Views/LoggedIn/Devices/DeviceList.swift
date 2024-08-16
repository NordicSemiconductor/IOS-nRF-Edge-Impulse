//
//  DeviceList.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI
import Combine
import os
import iOS_Common_Libraries

struct DeviceList: View {
    
    // MARK: Properties
    
    @EnvironmentObject var deviceData: DeviceData
    @EnvironmentObject var appData: AppData
    
    @State private var showDeleteDeviceAlert = false
    @State private var showRenameDeviceAlert = false
    @State private var renameText: String = ""
    
    @State private var alertDevice: Device? = nil
    
    private let logger = Logger(category: "DeviceList")
    
    // MARK: View
    
    var body: some View {
        FormIniOSListInMacOS {
            if appData.isLoggedIn {
                buildRegisteredDevicesList()
                buildScanResultsList()
            }
            
            #if os(macOS)
            MacAddressView()
                .padding(.vertical, 4)
            #endif
        }
        .textFieldAlert(title: "Rename Device", message: "New Device name here", isPresented: $showRenameDeviceAlert, text: $renameText, onPositiveAction: {
            guard let device = alertDevice else { return }
            appData.renameDevice(device, to: renameText) {
                self.deviceData.renamed(device, to: renameText)
                self.deviceData.updateRegisteredDevices()
            }
        })
        .background(Color.formBackground)
        .onAppear(perform: deviceData.updateRegisteredDevices)
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
    }
}

// MARK: - List

private extension DeviceList {
    
    // MARK: Scan results
    @ViewBuilder
    private func buildScanResultsList() -> some View {
        DeviceSection(title: "Add Device", data: deviceData.unregisteredDevices, emptyContentView: NoDevicesFoundView()) { s in
            UnregisteredDeviceView(s)
        }
    }
    
    // MARK: Registered Devices
    @ViewBuilder
    private func buildRegisteredDevicesList() -> some View {
        DeviceSection(title: "Devices", data: deviceData.registeredDevices, emptyContentView: NoRegisteredDevicesView()) { wrapper in
            NavigationLink(destination: DeviceDetails(device: wrapper.device, state: wrapper.state)) {
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
            .foregroundColor(.nordicRed)
        }
        
        Button(action: {
            alertDevice = deviceWrapper.device
            if let updatedWrapper = deviceData.registeredDevices.first(where: { $0.id == deviceWrapper.id }) {
                renameText = updatedWrapper.device.name
            } else {
                renameText = deviceWrapper.device.name
            }
            showRenameDeviceAlert = true
        }) {
            Label("Rename", systemImage: "pencil")
        }
        
        Divider()
        Button {
            alertDevice = deviceWrapper.device
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
        guard let device = alertDevice else { return }
        
        deviceData.tryToDelete(device: device)
        alertDevice = nil
    }
    
    func dismissDeleteDevice() {
        showDeleteDeviceAlert = false
        alertDevice = nil
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
            .setupNavBarBackground(with: Assets.navBarBackground.color)
            .setSingleColumnNavigationViewStyle()
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .environmentObject(Preview.projectsPreviewAppData)
                    .environmentObject(Preview.mockRegisteredDevices)
                    .previewDevice("iPhone 12")
                    .previewDisplayName("Registered Devices")
            }
            .setupNavBarBackground(with: Assets.navBarBackground.color)
            .setSingleColumnNavigationViewStyle()
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .environmentObject(Preview.projectsPreviewAppData)
                    .environmentObject(Preview.isScanningButNoDevicesScannerData)
                    .previewDevice("iPhone 12 mini")
            }
            .setupNavBarBackground(with: Assets.navBarBackground.color)
            .setSingleColumnNavigationViewStyle()
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .preferredColorScheme(.dark)
                    .environmentObject(Preview.projectsPreviewAppData)
                    .environmentObject(Preview.mockScannerData)
                    .previewDevice("iPad Pro (12.9-inch) (4th generation)")
            }
            .setupNavBarBackground(with: Assets.navBarBackground.color)
            .setSingleColumnNavigationViewStyle()
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .environmentObject(Preview.projectsPreviewAppData)
                    .environmentObject(Preview.mockScannerData)
                    .previewDevice("iPad Pro (12.9-inch) (4th generation)")
            }
            .setupNavBarBackground(with: Assets.navBarBackground.color)
            .setSingleColumnNavigationViewStyle()
        }
        #endif
    }
}
#endif
