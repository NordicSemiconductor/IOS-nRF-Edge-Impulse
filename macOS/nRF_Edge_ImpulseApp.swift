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
    
    @StateObject var dataContainer = DataContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataContainer.appData)
                .environmentObject(dataContainer.deviceData)
        }
        .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
        .commands {
            CommandGroup(after: CommandGroupPlacement.windowList) {
                Divider()
                
                ForEach(Tabs.availableCases) { tab in
                    commandForTab(tab)
                }
                
                if dataContainer.appData.isLoggedIn {
                    commandForTab(Tabs.User)
                }
            }
            
            CommandGroup(replacing: .appInfo) {
                aboutAppCommand()
            }
        }
        
        Settings {
            SettingsContentView()
                .environmentObject(dataContainer.appData)
        }
    }
}

// MARK: - Commands

extension nRF_Edge_ImpulseApp {
    
    @ViewBuilder
    func commandForTab(_ tab: Tabs) -> some View {
        Button("Show \(tab.description) Tab") {
            dataContainer.appData.selectedTab = tab
        }
        .keyboardShortcut(tab.keyboardShortcutKey, modifiers: .command)
    }
    
    @ViewBuilder
    func commandForSettings() -> some View {
        Button("Settings") {
            dataContainer.appData.selectedTab = .Settings
        }
        .keyboardShortcut(",", modifiers: .command)
    }
    
    @ViewBuilder
    func aboutAppCommand() -> some View {
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
