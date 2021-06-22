//
//  RegisteredDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 27/05/2021.
//

import SwiftUI

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
                    .lineLimit(1)
                Spacer()
                
                ConnectionStatus(color: connectionState.color)
            }
            
            Label("Details", systemImage: expanded ? "chevron.down" : "chevron.forward")
                .labelStyle(IconOnTheRightLabelStyle())
                .padding(.vertical, 2)
                .foregroundColor(Assets.middleGrey.color)
            
            if expanded {
                RegisteredDeviceDetailsView(device: device)
            }
        }
        .onTapGesture {
            expanded.toggle()
        }
        .padding()
    }
}

#if DEBUG
struct RegisteredDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegisteredDeviceView(device: .mock, connectionState: .connected, expanded: true)
            
            RegisteredDeviceView(device: .mock, connectionState: .notConnectable)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
