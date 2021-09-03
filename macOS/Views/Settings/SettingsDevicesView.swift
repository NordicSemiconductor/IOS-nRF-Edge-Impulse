//
//  SettingsDevicesView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI

struct SettingsDevicesView: View {
    
    @ObservedObject var preferences = UserPreferences.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Toggle("Only Scan Devices Advertising 'Edge Impulse Remote Management' Service",
                   isOn: $preferences.onlyScanUARTDevices)
            
            Toggle("Only Scan Connectable Devices",
                   isOn: $preferences.onlyScanConnectableDevices)
        }
        .frame(width: 300)
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsDevicesView()
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
