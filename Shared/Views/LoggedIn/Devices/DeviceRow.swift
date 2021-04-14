//
//  ProjectRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import SwiftUI

// MARK: - ProjectRow

struct DeviceRow: View {
    let scanResult: ScanResult
    
    var body: some View {
        HStack(alignment: .top) {
            SignalLevel(rssi: scanResult.rssi)
                .frame(width: 40, height: 30, alignment: .center)
            VStack(alignment: .leading) {
                Text(scanResult.name)
                    .font(.headline)
                    .bold()
            }
        }
        .padding(16)
    }
}

// MARK: - Preview

#if DEBUG
struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(scanResult: .sample)
    }
}
#endif
