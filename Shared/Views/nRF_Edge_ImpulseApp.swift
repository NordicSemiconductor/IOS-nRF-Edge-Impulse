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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataContainer.appData)
                .environmentObject(dataContainer.resourceData)
                .environmentObject(dataContainer.deiceData)
        }
    }
}
