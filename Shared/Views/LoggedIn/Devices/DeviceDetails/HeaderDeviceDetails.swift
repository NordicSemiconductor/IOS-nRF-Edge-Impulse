//
//  HeaderDeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/03/2021.
//

import SwiftUI
import os

struct HeaderDeviceDetails: View {
    let deviceHandler: DeviceRemoteHandler
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(deviceHandler.scanResult.name)
                        .font(.title)
                    Text(deviceHandler.scanResult.id.uuidString)
                }
                .padding(8)
                
                Spacer()
            }
            
            Button("Connect") {
                self.deviceHandler.connect()
                
            }
        
        }
    }
}

#if DEBUG
struct HeaderDeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        HeaderDeviceDetails(
            deviceHandler: DeviceRemoteHandler(scanResult: ScanResult(name: "Device 1", id: UUID(), rssi: .good, advertisementData: .mock)))
    }
}
#endif
