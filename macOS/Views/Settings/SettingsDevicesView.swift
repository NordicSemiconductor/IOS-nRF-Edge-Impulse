//
//  SettingsDevicesView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI

struct SettingsDevicesView: View {
    
    @State var a = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                Toggle("Only Show Devices Advertising 'UART' Service", isOn: $a)
                
                Toggle("Only Show Connectable Devices", isOn: $a)
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
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
