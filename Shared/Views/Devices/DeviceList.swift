//
//  DeviceList.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

struct DeviceList: View {
    @EnvironmentObject var scanner: Scanner
    
    init() {
        setupNavBar(backgroundColor: Assets.blue.uiColor, titleColor: .white)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(scanner.scannedDevices) { device in
                    Text(device.id.uuidString)
                        .lineLimit(1)
                }
            }
            .navigationTitle("Devices")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(scanner.isScanning ? "Stop Scanning" : "Start Scanning") {
                        scanner.toggle()
                    }
                }
            }
        }
        .accentColor(.white)
    }
}

// MARK: - Preview

#if DEBUG
struct DeviceList_Previews: PreviewProvider {
    
    static let previewScanner: Scanner = {
       let scanner = Scanner()
        scanner.scannedDevices = [
            Device(id: UUID()),
            Device(id: UUID()),
            Device(id: UUID()),
        ]
        return scanner
    }()
    
    static var previews: some View {
        DeviceList()
            .environmentObject(previewScanner)
            .previewDevice("iPhone 12 mini")
    }
}
#endif
