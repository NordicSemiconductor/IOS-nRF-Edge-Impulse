//
//  SettingsScannerView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI

struct SettingsScannerView: View {
    
    @ObservedObject var preferences = UserPreferences.shared
    
    var body: some View {
        VStack {
            Text("Filtering")
                .font(.subheadline)
                .bold()
            
            VStack(alignment: .leading, spacing: 10) {
                
                Toggle("Show Only Edge Impulse Devices",
                       isOn: $preferences.onlyScanUARTDevices)
                
                Toggle("Show Only Connectable Devices",
                       isOn: $preferences.onlyScanConnectableDevices)
            }
        }
        .frame(width: 300)
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsScannerView()
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
