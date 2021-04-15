//
//  SettingsContentView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 15/4/21.
//

import SwiftUI

struct SettingsContentView: View {
    
    @EnvironmentObject var preferencesData: PreferencesData
    
    // MARK: - View
    
    var body: some View {
        Form {
            Section(header: Text("Devices")) {
                Toggle("Only Scan Devices Advertising 'UART' Service",
                       isOn: $preferencesData.onlyScanUARTDevices)
                    .toggleStyle(SwitchToggleStyle(tint: Assets.blue.color))
                
                Toggle("Only Scan Connectable Devices",
                       isOn: $preferencesData.onlyScanConnectableDevices)
                    .toggleStyle(SwitchToggleStyle(tint: Assets.blue.color))
            }
            .accentColor(Assets.blue.color)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContentView()
            .environmentObject(PreferencesData())
    }
}
#endif
