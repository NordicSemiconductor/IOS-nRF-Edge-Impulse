//
//  nRF_Edge_ImpulseApp.swift
//  Shared
//
//  Created by Dinesh Harjani on 22/02/2021.
//

import SwiftUI

@main
struct nRF_Edge_ImpulseApp: App {
    
    @StateObject var dataContainer = DataContainer()
    @StateObject var hudState = HUDState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .hud(isPresented: $hudState.isPresented) {
                    Label(hudState.title, systemImage: hudState.systemImage)
                }
                .environmentObject(dataContainer.appData)
                .environmentObject(dataContainer.resourceData)
                .environmentObject(dataContainer.deviceData)
                .environmentObject(hudState)
        }
    }
}
