//
//  SettingsDevicesView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI

struct SettingsDevicesView: View {
    
    @EnvironmentObject var preferencesData: PreferencesData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                Toggle("Only Scan Devices Advertising 'UART' Service",
                       isOn: $preferencesData.onlyScanUARTDevices)
                
                Toggle("Only Scan Connectable Devices",
                       isOn: $preferencesData.onlyScanConnectableDevices)
            }
            .frame(width: 300)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsDevicesView()
                .environmentObject(PreferencesData())
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
