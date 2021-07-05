//
//  SettingsContentView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 15/4/21.
//

import SwiftUI

struct SettingsContentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var resourceData: ResourceData
    
    @ObservedObject var preferences = UserPreferences.shared
    
    // MARK: - View
    
    var body: some View {
        Form {
            Section(header: VStack(alignment: .center, spacing: 0) {
                EmptyView()
            }) {
                if let user = appData.user {
                    NavigationLink(destination: UserContentView()) {
                        UserView(user: user)
                    }
                } else {
                    Text("User Data Unavailable")
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("Devices")) {
                Toggle("Only Scan Devices Advertising 'UART' Service",
                       isOn: $preferences.onlyScanUARTDevices)
                    .toggleStyle(SwitchToggleStyle(tint: Assets.blue.color))
                
                Toggle("Only Scan Connectable Devices",
                       isOn: $preferences.onlyScanConnectableDevices)
                    .toggleStyle(SwitchToggleStyle(tint: Assets.blue.color))
            }
            
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
            
            #if DEBUG
            Section(header: Text("Debug")) {
                Button("Test Error", action: appData.raiseTestError)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            #endif
            
            Section(header: Text("About App")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Constant.appVersion)
                        .foregroundColor(.gray)
                }
            }
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
                    .environmentObject(AppData())
            }
            .setBackgroundColor(.blue)
            
            NavigationView {
                SettingsContentView()
                    .setTitle("Settings")
                    .environmentObject(Preview.noDevicesAppData)
            }
            .setBackgroundColor(.blue)
        }
        .previewDevice("iPhone 12 mini")
        .environmentObject(ResourceData())
    }
}
#endif
