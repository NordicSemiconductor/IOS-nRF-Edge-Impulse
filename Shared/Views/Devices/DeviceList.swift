//
//  DeviceList.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

struct DeviceList: View {
    @StateObject var scanner = Scanner()
    
    init() {
        setupNavBar(backgroundColor: Assets.blue.uiColor, titleColor: .white)
    }
    
    var body: some View {
        NavigationView {
            List(scanner.scannedDevices) { device in
                Text(device.id.uuidString)
            }
            .navigationTitle("Devices")
        }
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
