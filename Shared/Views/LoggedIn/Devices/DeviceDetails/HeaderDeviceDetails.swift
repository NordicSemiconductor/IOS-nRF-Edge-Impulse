//
//  HeaderDeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/03/2021.
//

import SwiftUI

struct HeaderDeviceDetails: View {
    let btManager: BluetoothManager
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
                do {
                    try self.btManager.connect()
                } catch let e {
                    print(e.localizedDescription)
                }
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
        HeaderDeviceDetails(btManager: BluetoothManager(peripheralId: UUID()), scanResult: ScanResult(name: "Device 1", id: UUID(), rssi: .good, advertisementData: .mock))
    }
}
#endif
