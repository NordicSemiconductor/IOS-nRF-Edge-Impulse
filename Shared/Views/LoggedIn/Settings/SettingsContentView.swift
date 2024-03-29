//
//  SettingsContentView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 15/4/21.
//

import SwiftUI
import iOS_Common_Libraries

struct SettingsContentView: View {
    
    @EnvironmentObject var appData: AppData
    
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
            
            Section(header: Text("Scanner Settings")) {
                Toggle("Show Only Edge Impulse Devices",
                       isOn: $preferences.onlyScanUARTDevices)
                .toggleStyle(SwitchToggleStyle(tint: .nordicBlue))
                
                Toggle("Show Only Connectable Devices",
                       isOn: $preferences.onlyScanConnectableDevices)
                .toggleStyle(SwitchToggleStyle(tint: .nordicBlue))
            }
            
            #if DEBUG
            Section(header: Text("Debug")) {
                Button("Test Error", action: appData.raiseTestError)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            #endif
            
            Section(header: Text("About App")) {
                HStack {
                    Text("Application Version")
                    Spacer()
                    Text(Constant.appVersion)
                        .foregroundColor(.gray)
                }
            }
        }
        .accentColor(.nordicBlue)
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
            .setupNavBarBackground(with: Assets.navBarBackground.color)
            
            NavigationView {
                SettingsContentView()
                    .setTitle("Settings")
                    .environmentObject(Preview.noDevicesAppData)
            }
            .setupNavBarBackground(with: Assets.navBarBackground.color)
        }
        .previewDevice("iPhone 12 mini")
    }
}
#endif
