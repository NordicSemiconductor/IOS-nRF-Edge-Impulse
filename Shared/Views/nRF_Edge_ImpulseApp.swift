//
//  nRF_Edge_ImpulseApp.swift
//  Shared
//
//  Created by Dinesh Harjani on 22/02/2021.
//

import SwiftUI

class DataContainer: ObservableObject {
    let appData = AppData()
    let resourceData = ResourceData()
    lazy var deiceData = DeviceData(appData: self.appData)
}

@main
struct nRF_Edge_ImpulseApp: App {
    
//    @StateObject var appData = AppData()
//    @StateObject var resourceData = ResourceData()
    
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
