//
//  UnregisteredDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import SwiftUI

// MARK: - UnregisteredDeviceView

struct UnregisteredDeviceView: View {
    
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
            DeviceIconView(name: scanResult.isConnectable ? "cpu" : "bolt.slash",
                           color: Assets.darkGrey.color)
            
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
            .padding(.horizontal, 4)
            
            Spacer()
            
            HStack {
                if !scanResult.isConnectable {
                    Text("Not Connectable")
                        .font(.caption)
                        .foregroundColor(Assets.middleGrey.color)
                } else if isConnecting {
                    CircularProgressView()
                }
            }
            .padding(.horizontal)
        }
    }
    
    var deviceForegroundColor: Color {
        return Assets.blue.color
    }
}

// MARK: - Preview

#if DEBUG
struct UnregisteredDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UnregisteredDeviceView(.sample)
            UnregisteredDeviceView(.unconnectableSample)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
