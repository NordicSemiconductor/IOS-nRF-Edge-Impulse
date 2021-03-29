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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
        }
    }
}