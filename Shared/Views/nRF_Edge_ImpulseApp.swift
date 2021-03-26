//
//  nRF_Edge_ImpulseApp.swift
//  Shared
//
//  Created by Dinesh Harjani on 22/02/2021.
//

import SwiftUI

@main
struct nRF_Edge_ImpulseApp: App {
    
    @Environment(\.openURL) var openURL
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var appData = AppData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
        }
        
        WindowGroup("Open") {
            if case .openDevice(let device)? = appData.openWindow {
                DeviceDetails(scanResult: device)
                    .environmentObject(appData)
                    .onOpenURL(perform: { url in
                        print("Hello \(url)")
                    })
            }
        }
        .commands {
            CommandGroup(replacing: .newItem, addition: { })
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "//aa"))
        
    }
}
