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
    @StateObject var deviceData = DeviceData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
                .environmentObject(resourceData)
                .environmentObject(deviceData)
        }
    }
}
