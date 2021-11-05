//
//  BoolDeviceInfoRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/9/21.
//

import SwiftUI

internal struct BoolDeviceInfoRow: View {
    
    let title: String
    let systemImage: String?
    let enabled: Bool
    
    var body: some View {
        HStack {
            Label(
                title: { Text(title) },
                icon: {
                    Image(systemName: systemImage ?? "")
                        .renderingMode(.template)
                        .foregroundColor(.universalAccentColor)
                }
            )
            Spacer()
            
            Text(enabled ? "Yes" : "No")
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct BoolDeviceInfoRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            BoolDeviceInfoRow(title: "Supports Snapshot Streaming", systemImage: "arrow.left.and.right", enabled: Device.connectableMock.supportsSnapshotStreaming)
        }
        .previewLayout(.sizeThatFits)
        
    }
}
#endif
