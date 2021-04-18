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
                .tabItem {
                    Label(Tabs.Devices.description, systemImage: Tabs.Devices.systemImageName)
                }
                .tag(Tabs.Devices)
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
    }
}
#endif
