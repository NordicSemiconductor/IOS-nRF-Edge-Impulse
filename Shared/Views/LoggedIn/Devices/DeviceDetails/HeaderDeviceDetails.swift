//
//  HeaderDeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/03/2021.
//

import SwiftUI
import os

struct HeaderDeviceDetails: View {
    @EnvironmentObject var deviceData: DeviceData
    let device: Device
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(device.name)
                        .font(.title)
                    Text(device.id.uuidString)
                }
                .padding(8)
                
                Spacer()
            }
            
            viewForHandler(deviceData.deviceHandler(for: device))
        }
    }
        
    @ViewBuilder
    private func viewForHandler(_ handler: DeviceRemoteHandler) -> some View {
        switch handler.device.state {
        case .notConnected:
            Button("Connect") {
                handler.connect()
            }
        case .connecting:
            ProgressView()
        case .ready:
            Button("Disconnect") {
                handler.disconnect()
            }
        case .error:
            // TODO: Add error handler
            Text("Error")
        }
    }
}

#if DEBUG
struct HeaderDeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        HeaderDeviceDetails(device: Device.sample)
    }
}
#endif
