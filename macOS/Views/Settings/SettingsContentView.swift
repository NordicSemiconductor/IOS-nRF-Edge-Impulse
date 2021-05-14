//
//  SettingsContentView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI

struct SettingsContentView: View {
    
    var body: some View {
        TabView {
            SettingsDevicesView()
                .withTabBarStyle()
                .tabItem {
                    Label(Tabs.Devices.description, systemImage: Tabs.Devices.systemImageName)
                }
                .tag(0)
            
            SettingsSyncView()
                .withTabBarStyle()
                .tabItem {
                    Label("UUID Sync", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(1)
            
            #if DEBUG
            SettingsDebugView()
                .withTabBarStyle()
                .tabItem {
                    Label("Debug", systemImage: "ladybug.fill")
                }
                .tag(99)
            #endif
        }
        .padding(20)
        .frame(width: 375, height: 150)
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContentView()
            .environmentObject(Preview.noDevicesAppData)
            .environmentObject(ResourceData())
    }
}
#endif
