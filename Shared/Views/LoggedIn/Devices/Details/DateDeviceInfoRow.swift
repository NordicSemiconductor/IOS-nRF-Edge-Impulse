//
//  DateDeviceInfoRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/11/21.
//

import SwiftUI

struct DateDeviceInfoRow: View {
    
    @EnvironmentObject private var hudState: HUDState
    
    let title: String
    let systemImage: String?
    let content: Date
    
    var body: some View {
        HStack {
            NordicLabel(title: title, systemImage: systemImage ?? "")
            Spacer()
            
            Text(content, style: .date)
                .bold()
                .lineLimit(1)
                .onLongPressGesture {
                    #if os(iOS)
                    UIPasteboard.general.string = content.formatterString()
                    #elseif os(OSX)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(content.formatterString(), forType: .string)
                    #endif
                    hudState.show(title: "Copied", systemImage: "doc.on.doc")
                }
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DateDeviceInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        DateDeviceInfoRow(title: "Date:", systemImage: "clock.fill", content: Date())
    }
}
#endif
