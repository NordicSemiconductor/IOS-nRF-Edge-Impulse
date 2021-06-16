//
//  nRF_Edge_ImpulseApp.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 26/3/21.
//

import Foundation

import SwiftUI

@main
struct nRF_Edge_ImpulseApp: App {
    
    @StateObject var appData = AppData()
    @StateObject var scannerData = Scanner()
    @StateObject var resourceData = ResourceData()
    @StateObject var registeredDeviceData = RegisteredDevicesData()
    @StateObject lazy var devicesData: DeviceData = {
        DeviceData(scannerData: scannerData, registeredDevicesData: registeredDeviceData, appData: appData)
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
                .environmentObject(scannerData)
                .environmentObject(resourceData)
                .environmentObject(registeredDeviceData)
                .environmentObject(devicesData)
        }
        .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About \(Constant.appName)") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: Constant.aboutEdgeImpulse,
                                attributes: [
                                    NSAttributedString.Key.font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
                                ]
                            ),
                            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): Constant.copyright]
                    )
                }
            }
        }
        
        Settings {
            SettingsContentView()
                .environmentObject(appData)
                .environmentObject(resourceData)
        }
    }
}
