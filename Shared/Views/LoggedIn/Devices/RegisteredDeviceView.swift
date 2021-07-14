//
//  RegisteredDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 27/05/2021.
//

import SwiftUI

struct RegisteredDeviceView: View {
    let device: RegisteredDevice
    let connectionState: DeviceData.RegisteredDeviceWrapper.State
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(device.name)
                    .font(.headline)
                    .bold()
                    .lineLimit(1)
                Spacer()
                if case .connecting = connectionState {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 20, height: 20)
                } else {
                    ConnectionStatus(color: connectionState.color)                    
                }
            }
            
            Text("ID: \(device.deviceId)")
                .labelStyle(IconOnTheRightLabelStyle())
                .padding(.vertical, 2)
                .foregroundColor(Assets.middleGrey.color)
                .lineLimit(1)
        }
        .padding(4)
    }
}

#if DEBUG
struct RegisteredDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegisteredDeviceView(device: .mock, connectionState: .notConnectable)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
