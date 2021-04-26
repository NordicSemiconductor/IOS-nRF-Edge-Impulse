//
//  HeaderDeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/03/2021.
//

import SwiftUI
import os

struct HeaderDeviceDetails: View {
    
    @EnvironmentObject var scannerData: ScannerData
    
    private let device: Device
    
    // MARK: Init
    
    init(_ device: Device) {
        self.device = device
    }
    
    // MARK: View
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(device.name)
                        .font(.title)
                    Text(device.id.uuidString)
                }
                .padding(8)
                
                Spacer()
            }
            
            viewForHandler(scannerData[device])
        }
    }
        
    @ViewBuilder
    private func viewForHandler(_ handler: DeviceRemoteHandler) -> some View {
        switch handler.device.state {
        case .notConnected:
            Button("Connect", action: handler.connect)
        case .connecting:
            ProgressView()
        case .ready:
            Button("Disconnect", action: handler.disconnect)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct HeaderDeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HeaderDeviceDetails(Device.sample)
                .environmentObject(Preview.mockScannerData)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
