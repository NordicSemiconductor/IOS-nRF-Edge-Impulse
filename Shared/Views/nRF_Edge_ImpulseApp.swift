//
//  nRF_Edge_ImpulseApp.swift
//  Shared
//
//  Created by Dinesh Harjani on 22/02/2021.
//

import SwiftUI

@main
struct nRF_Edge_ImpulseApp: App {
    
    @StateObject var appData = AppData()
    @StateObject var resourceData = ResourceData()
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                deviceData: DeviceData(
                    scannerData: ScannerData(),
                    registeredDevicesData: RegisteredDevicesData(),
                    appData: appData
                )
            )
            .environmentObject(appData)
            .environmentObject(resourceData)
        }
    }
}
