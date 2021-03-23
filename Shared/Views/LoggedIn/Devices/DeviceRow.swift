//
//  ProjectRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import SwiftUI

// MARK: - ProjectRow

struct DeviceRow: View {
    let device: Device
    
    var body: some View {
        HStack(alignment: .top) {
            SignalLevel(rssi: device.rssi)
                .frame(width: 40, height: 30, alignment: .center)
            VStack(alignment: .leading) {
                Text(device.name)
                    .font(.headline)
                    .bold()
                Text(device.id.uuidString)
                    .font(.body)
                    .lineLimit(1)
            }
        }
        .padding(16)
    }
}

// MARK: - Preview

#if DEBUG
struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(device: .sample)
    }
}
#endif
