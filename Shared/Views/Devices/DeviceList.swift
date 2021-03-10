//
//  DeviceList.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI
import Combine

struct DeviceList: View {
    @EnvironmentObject var scanner: Scanner
    
    @State private var scannedDevices: [Device] = []
    @State private var scannerCancellable: Cancellable? = nil
    
    init() {
        setupNavBar(backgroundColor: Assets.blue.uiColor, titleColor: .white)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(scannedDevices) { device in
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
            .onAppear() {
                scannerCancellable = scanner.devicePublisher
                    .throttle(for: 1.0, scheduler: RunLoop.main, latest: false)
                    .sink(receiveCompletion: { result in
                        print(result)
                    }, receiveValue: { device in
                        guard !scannedDevices.contains(device) else { return }
                        scannedDevices.append(device)
                    })
            }
            .onDisappear() {
                scannerCancellable?.cancel()
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
//        scanner.scannedDevices = [
//            Device(id: UUID()),
//            Device(id: UUID()),
//            Device(id: UUID()),
//        ]
        return scanner
    }()
    
    static var previews: some View {
        DeviceList()
            .environmentObject(previewScanner)
            .previewDevice("iPhone 12 mini")
    }
}
#endif
