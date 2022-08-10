//
//  UnregisteredDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import SwiftUI

// MARK: - UnregisteredDeviceView

struct UnregisteredDeviceView: View {
    
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: Private Properties
    
    private let scanResult: ScanResult
    private let isConnecting: Bool
    
    // MARK: Init
    
    init(_ scanResultWrapper: DeviceData.ScanResultWrapper) {
        self.scanResult = scanResultWrapper.scanResult
        self.isConnecting = scanResultWrapper.state == .connecting
    }
    
    // MARK: View
    
    var body: some View {
        HStack {
            DeviceIconView(name: scanResult.isConnectable ? "cpu" : "bolt.slash",
                           color: .nordicDarkGrey)
            
            VStack(alignment: .leading) {
                Text(scanResult.name)
                    .font(.headline)
                    .foregroundColor(deviceForegroundColor)
                    .bold()
                
                if !scanResult.isConnectable {
                    Text("Not Connectable")
                        .font(.caption)
                        .foregroundColor(.nordicMiddleGrey)
                }
                

            }
            .padding(.horizontal, 4)
            
            Spacer()
            
            if isConnecting {
                CircularProgressView()
                    .foregroundColor(.nordicMiddleGrey)
                    .padding(.horizontal, 4)
            }
            
            HStack {
                SignalLevel(rssi: scanResult.rssi)
                    .frame(width: 20, height: 15, alignment: .center)

                Text("\(scanResult.rssi.value) dB")
                    .foregroundColor(deviceForegroundColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    var deviceForegroundColor: Color { .nordicBlue }
    
    func onTap() {
        guard scanResult.isConnectable else { return }
        deviceData.tryToConnect(scanResult: scanResult)
    }
}

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

struct UnregisteredDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UnregisteredDeviceView(DeviceData.ScanResultWrapper(scanResult: .sample))
            UnregisteredDeviceView(Preview.connectingDeviceWrapper)
            UnregisteredDeviceView(DeviceData.ScanResultWrapper(scanResult: .unconnectableSample))
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
