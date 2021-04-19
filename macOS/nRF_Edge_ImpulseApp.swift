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
    @StateObject var deviceData = DeviceData()
    @StateObject var preferencesData = PreferencesData()
    @StateObject var resourceData = ResourceData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
                .environmentObject(deviceData)
                .environmentObject(preferencesData)
                .environmentObject(resourceData)
        }
        
        Settings {
            SettingsContentView()
                .environmentObject(preferencesData)
        }
    }
}
