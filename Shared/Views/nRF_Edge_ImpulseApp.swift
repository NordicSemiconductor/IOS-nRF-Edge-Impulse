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
    @StateObject var preferencesData = PreferencesData()
    @StateObject var resourceData = ResourceData()
    @StateObject var scannerData = ScannerData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
                .environmentObject(preferencesData)
                .environmentObject(resourceData)
                .environmentObject(scannerData)
        }
    }
}
