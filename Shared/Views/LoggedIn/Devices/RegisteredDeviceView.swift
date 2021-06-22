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
                Spacer()
                
                ConnectionStatus(color: connectionState.color)
            }
            
            if expanded {
                RegisteredDeviceDetailsView(device: device)
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
