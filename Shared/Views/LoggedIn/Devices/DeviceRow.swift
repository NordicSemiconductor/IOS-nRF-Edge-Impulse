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
    private let connectionType: DeviceAccessoryView.DeviceType
    
    // MARK: Init
    
    init(_ device: Device, connectionType: DeviceAccessoryView.DeviceType) {
        self.device = device
        self.connectionType = connectionType
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
            DeviceAccessoryView(deviceType: connectionType)
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12))
        
    }
    
    var deviceForegroundColor: Color {
        guard device.state == .notConnected else {
            return Assets.blue.color
        }
        return scannerData.isScanning ? .primary : Assets.middleGrey.color
    }
}

// MARK: - Preview

#if DEBUG
struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(.sample, connectionType: .connected)
            .environmentObject(Preview.mockScannerData)
            .previewLayout(.sizeThatFits)
    }
}
#endif
