//
//  RegisteredDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 27/05/2021.
//

import SwiftUI

// MARK: - RegisteredDeviceView

struct RegisteredDeviceView: View {
    
    private let device: Device
    private let text: String
    private let connectionState: DeviceData.DeviceWrapper.State
    
    // MARK: Init
    
    init(_ device: Device, connectionState: DeviceData.DeviceWrapper.State) {
        self.device = device
        var text = device.name
        if connectionState == .deleting {
            text += " (Deleting...)"
        }
        self.text = text
        self.connectionState = connectionState
    }
    
    // MARK: View
    
    var body: some View {
        HStack {
            DeviceIconView(name: "cpu", color: connectionState.color)
            
            Text(text)
                .font(.headline)
                .bold()
                .lineLimit(1)
                .foregroundColor(connectionState == .deleting ? .gray : .textColor)
            
            Spacer()
            
            if connectionState == .connecting || connectionState == .deleting {
                CircularProgressView()
            }
        }
    }
}

// MARK: - Preview

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
