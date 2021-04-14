//
//  DeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/03/2021.
//

import SwiftUI

struct DeviceDetails: View {
    let device: DeviceRemoteHandler
    
    var body: some View {
        VStack(alignment: .center) {
            HeaderDeviceDetails(deviceHandler: device)
            Divider()
            Spacer()
        }
    }
}

#if DEBUG
struct DeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetails(device: DeviceRemoteHandler.mock)
    }
}
#endif
