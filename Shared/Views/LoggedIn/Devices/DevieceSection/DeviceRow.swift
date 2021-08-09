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
    
    private let scanResult: ScanResult
    private let isConnecting: Bool
    
    // MARK: Init
    
    init(_ device: ScanResult, isConnecting: Bool = false) {
        self.scanResult = device
        self.isConnecting = isConnecting
    }
    
    // MARK: View
    
    var body: some View {
        HStack {
            HStack(alignment: .top) {
                Image(systemName: "candybarphone")
                    .foregroundColor(deviceForegroundColor)
                
                VStack(alignment: .leading) {
                    Text(scanResult.name)
                        .font(.headline)
                        .foregroundColor(deviceForegroundColor)
                        .bold()
                    
                    HStack {
                        SignalLevel(rssi: scanResult.rssi)
                            .frame(width: 20, height: 15, alignment: .center)
                        
                        Text("\(scanResult.rssi.value) dB")
                            .foregroundColor(deviceForegroundColor)
                    }
                }
            }
            .padding(8)
            Spacer()
            if isConnecting {
                ProgressView()
            }
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
            .previewLayout(.sizeThatFits)
    }
}
#endif