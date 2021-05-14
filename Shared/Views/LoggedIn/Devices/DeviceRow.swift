//
//  ProjectRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import SwiftUI

// MARK: - ProjectRow

struct DeviceRow: View {
    
    // MARK: Private Properties
    
    private let device: Device
    
    // MARK: Init
    
    init(_ device: Device) {
        self.device = device
    }
    
    // MARK: View
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "candybarphone")
            
            VStack(alignment: .leading) {
                Text(device.name)
                    .font(.headline)
                    .bold()
                
                HStack {
                    SignalLevel(rssi: device.rssi)
                        .frame(width: 20, height: 15, alignment: .center)
                    
                    Text("\(device.rssi.rawValue) dB")
                }
            }
        }
        .padding(8)
    }
}

// MARK: - Preview

#if DEBUG
struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(.sample)
            .previewLayout(.sizeThatFits)
    }
}
#endif
