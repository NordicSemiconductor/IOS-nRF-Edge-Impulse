//
//  RegisteredDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 27/05/2021.
//

import SwiftUI

struct RegisteredDeviceView: View {
    
    private let deviceWrapper: DeviceData.DeviceWrapper
    
    private var device: Device { deviceWrapper.device }
    private var connectionState: DeviceData.DeviceWrapper.State { deviceWrapper.state }
    
    init(_ deviceWrapper: DeviceData.DeviceWrapper) {
        self.deviceWrapper = deviceWrapper
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
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 20, height: 20)
            }
        }
    }
}

#if DEBUG
struct RegisteredDeviceView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            ForEach(DeviceData.DeviceWrapper.State.allCases, id: \.self) { state in
                RegisteredDeviceView(DeviceData.DeviceWrapper(device: .connectableMock))
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
