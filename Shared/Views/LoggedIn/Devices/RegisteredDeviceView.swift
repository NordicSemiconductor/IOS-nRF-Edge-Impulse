//
//  RegisteredDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 27/05/2021.
//

import SwiftUI

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

struct RegisteredDeviceView: View {
    let device: RegisteredDevice
    let connectionState: DeviceData.RemoteDeviceWrapper.State
    @State var expanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(device.name)
                    .font(.headline)
                    .bold()
                Spacer()
                
                ConnectionStatus(color: connectionState.color)
            }
            
            if expanded {
                buildExpandedView()
            } else {
                Text(device.deviceId)
                    .font(.subheadline)
                    .bold()
            }
        }
        .onTapGesture {
            expanded.toggle()
        }
        .padding()
    }
    
    @ViewBuilder
    private func buildExpandedView() -> some View {
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

#if DEBUG
struct RegisteredDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegisteredDeviceView(device: .mock, connectionState: .connected, expanded: true)
                .previewLayout(.sizeThatFits)
            
            RegisteredDeviceView(device: .mock, connectionState: .notConnectable, expanded: false)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
