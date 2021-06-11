//
//  ProjectRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import SwiftUI

// MARK: - ProjectRow

struct DeviceRow: View {
    
    @EnvironmentObject var scannerData: ScannerData
    
    // MARK: Private Properties
    
    private let device: Device
    
    // MARK: Init
    
    init(_ device: Device) {
        self.device = device
    }
    
    // MARK: View
    
    var body: some View {
        HStack {
            HStack(alignment: .top) {
                Image(systemName: "candybarphone")
                    .foregroundColor(deviceForegroundColor)
                
                VStack(alignment: .leading) {
                    Text(device.name)
                        .font(.headline)
                        .foregroundColor(deviceForegroundColor)
                        .bold()
                    
                    HStack {
                        SignalLevel(rssi: device.rssi)
                            .frame(width: 20, height: 15, alignment: .center)
                        
                        Text("\(device.rssi.rawValue) dB")
                            .foregroundColor(deviceForegroundColor)
                    }
                }
            }
            .padding(8)
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12))
        
    }
    
    var deviceForegroundColor: Color {
        return Assets.blue.color
    }
}

// MARK: - Preview

#if DEBUG
struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(.sample)
            .environmentObject(Preview.mockScannerData)
            .previewLayout(.sizeThatFits)
    }
}
#endif
