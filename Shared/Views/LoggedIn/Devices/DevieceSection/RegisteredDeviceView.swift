//
//  RegisteredDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 27/05/2021.
//

import SwiftUI

struct RegisteredDeviceView: View {
    
    private let device: Device
    private let connectionState: DeviceData.DeviceWrapper.State
    
    init(_ device: Device, connectionState: DeviceData.DeviceWrapper.State) {
        self.device = device
        self.connectionState = connectionState
    }
    
    var body: some View {
        HStack {
            DeviceIconView(name: "cpu", color: connectionState.color)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(device.name)
                        .font(.headline)
                        .bold()
                        .lineLimit(1)
                        .foregroundColor(connectionState == .deleting ? .gray : .textColor)
                }
                
                Text(connectionState == .deleting ? "Deleting..." : "ID: \(device.deviceId)")
                    .labelStyle(IconOnTheRightLabelStyle())
                    .padding(.vertical, 2)
                    .foregroundColor(Assets.middleGrey.color)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            
            Spacer()
            
            if connectionState == .connecting || connectionState == .deleting {
                CircularProgressView()
            }
        }
    }
}

#if DEBUG
struct RegisteredDeviceView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            ForEach(DeviceData.DeviceWrapper.State.allCases, id: \.self) { state in
                RegisteredDeviceView(.connectableMock, connectionState: state)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
