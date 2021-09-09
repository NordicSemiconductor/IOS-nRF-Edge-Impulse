//
//  StringDeviceInfoRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/9/21.
//

import SwiftUI

struct StringDeviceInfoRow: View {
    
    @EnvironmentObject private var hudState: HUDState
    
    let title: String
    let systemImage: String?
    let content: String
    
    var body: some View {
        HStack {
            NordicLabel(title: title, systemImage: systemImage ?? "")
            Spacer()
            
            Text(content)
                .bold()
                .lineLimit(1)
                .onLongPressGesture {
                    #if os(iOS)
                    UIPasteboard.general.string = content
                    #elseif os(OSX)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(content, forType: .string)
                    #endif
                    hudState.show(title: "Copied", systemImage: "doc.on.doc")
                }
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct StringDeviceInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StringDeviceInfoRow(title: "Name:", systemImage: "character", content: Device.connectableMock.name)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
