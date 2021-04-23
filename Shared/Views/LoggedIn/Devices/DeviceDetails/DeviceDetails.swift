//
//  DeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/03/2021.
//

import SwiftUI

struct DeviceDetails: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var scannerData: ScannerData
    
    let device: Device
    
    var body: some View {
        VStack(alignment: .center) {
            HeaderDeviceDetails(device)
            Divider()
            Spacer()
        }
    }
}

#if DEBUG
struct DeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetails(device: Device.sample)
    }
}
#endif
