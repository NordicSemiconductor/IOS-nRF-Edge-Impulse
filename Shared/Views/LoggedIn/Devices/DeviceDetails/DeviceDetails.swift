//
//  DeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/03/2021.
//

import SwiftUI

struct DeviceDetails: View {
    let scanResult: ScanResult
    
    var body: some View {
        VStack(alignment: .center) {
            HeaderDeviceDetails(deviceHandler: DeviceRemoteHandler(scanResult: scanResult))
            Divider()
            Spacer()
        }
    }
}

#if DEBUG
struct DeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetails(scanResult: ScanResult(name: "Device 1", id: UUID(), rssi: .good, advertisementData: .mock))
    }
}
#endif
