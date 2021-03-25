//
//  HeaderDeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/03/2021.
//

import SwiftUI

struct HeaderDeviceDetails: View {
    let scanResult: ScanResult
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(scanResult.name)
                        .font(.title)
                    Text(scanResult.id.uuidString)
                }
                .padding(8)
                
                Spacer()
            }
            
            let connectable = scanResult.advertisementData.isConnectable == true
            
            Button("Connect") {
                
            }
            .disabled(!connectable)
            
            if (!connectable) {
                Text("The device is not connectable")
            }
            
        }
        
        
    }
}

#if DEBUG
struct HeaderDeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        HeaderDeviceDetails(scanResult: ScanResult(name: "Device 1", id: UUID(), rssi: .good, advertisementData: .mock))
    }
}
#endif
