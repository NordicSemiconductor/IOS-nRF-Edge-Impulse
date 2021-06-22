//
//  RegisteredDeviceDetailsView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/6/21.
//

import SwiftUI

struct RegisteredDeviceDetailsView: View {
    
    let device: RegisteredDevice
    
    var body: some View {
        VStack {
            TextStack("ID:", device.deviceId)
            TextStack("Created:", device.created)
            TextStack("Last seen:", device.lastSeen)
            TextStack("Device type:", device.deviceType)
            
            HStack(alignment: .center) {
                Spacer()
                Button("Connect") {
                    
                }
                Spacer()
            }
        }
    }
}

// MARK: - TextStack

private struct TextStack: View {
    let leadingText: String
    let trailingText: String
    
    init(_ leadingText: String, _ trailingText: String) {
        self.leadingText = leadingText
        self.trailingText = trailingText
    }
    
    var body: some View {
        HStack {
            Text(leadingText)
                .font(.headline)
                .bold()
            Spacer()
            Text(trailingText)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct RegisteredDeviceDetailsView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            RegisteredDeviceDetailsView(device: .mock)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
