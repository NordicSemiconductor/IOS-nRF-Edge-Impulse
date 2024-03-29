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
            SettingsScannerView()
                .withTabBarStyle()
                .tabItem {
                    Label("Scanner", systemImage: "dot.radiowaves.left.and.right")
                }
                .tag(0)
            
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
import iOS_Common_Libraries

struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContentView()
            .environmentObject(Preview.noDevicesAppData)
    }
}
#endif
