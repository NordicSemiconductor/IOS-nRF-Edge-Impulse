//
//  SettingsContentView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 15/4/21.
//

import SwiftUI

struct SettingsContentView: View {
    
    @EnvironmentObject var preferencesData: PreferencesData
    @EnvironmentObject var resourceData: ResourceData
    
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
            .padding(.top, 8)
            
            Section(header: Text("UUID Database")) {
                HStack {
                    Text("Status")
                    Spacer()
                    resourceData.status.label()
                }
                
                HStack {
                    Text("Last Check")
                    Spacer()
                    Text(resourceData.lastCheckDateString ?? "N/A")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Last SHA")
                    Spacer()
                    Text(resourceData.lastSavedSHA?.prefix(7) ?? "N/A")
                        .foregroundColor(.gray)
                }
                
                Button("Trigger Update", action: resourceData.forceUpdate)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .lineLimit(1)
        }
        .accentColor(Assets.blue.color)
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SettingsContentView()
                    .setTitle("Settings")
            }
            .setBackgroundColor(.blue)
        }
        .previewDevice("iPhone 12 mini")
        .environmentObject(PreferencesData())
        .environmentObject(ResourceData())
    }
}
#endif
