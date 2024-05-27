//
//  nRF_Edge_ImpulseApp.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 26/3/21.
//

import Foundation

import SwiftUI
import iOS_Common_Libraries

// MARK: - Mac Edge Impulse App

@main
struct nRF_Edge_ImpulseApp: App {
    
    // MARK: Properties
    
    @StateObject private var dataContainer = DataContainer()
    
    // MARK: View
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataContainer.appData)
                .environmentObject(dataContainer.deviceData)
        }
        .windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
        .commands {
            CommandGroup(before: .appTermination) {
                logoutCommand()
                
                Divider()
            }
            
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
            
            CommandGroup(replacing: .help) {
                openGitHubIssue()
                goToDevZone()
                
                Divider()
                
                contactEdgeImpulseCommand()
                openEdgeImpulseForum()
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
    func logoutCommand() -> some View {
        Button("Logout") {
            dataContainer.appData.logout()
        }
    }
    
    @ViewBuilder
    func aboutAppCommand() -> some View {
        Button("About nRF Edge Impulse") {
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
    
    // MARK: Help
    
    @ViewBuilder
    func openGitHubIssue() -> some View {
        Button("Open Issue") {
            openUrl("https://github.com/NordicSemiconductor/IOS-nRF-Edge-Impulse/issues")
        }
    }
    
    @ViewBuilder
    func goToDevZone() -> some View {
        Button("Go to Nordic DevZone") {
            openUrl("https://devzone.nordicsemi.com/")
        }
    }
    
    @ViewBuilder
    func contactEdgeImpulseCommand() -> some View {
        Button("Contact Edge Impulse") {
            openUrl("https://edgeimpulse.com/contact")
        }
    }
    
    @ViewBuilder
    func openEdgeImpulseForum() -> some View {
        Button("Go to Edge Impulse Forum") {
            openUrl("https://forum.edgeimpulse.com/")
        }
    }
    
    // MARK: - Private
    
    private func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
}
