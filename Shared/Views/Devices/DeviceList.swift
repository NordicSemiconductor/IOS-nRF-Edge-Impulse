//
//  DeviceList.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI
import Combine

struct DeviceList: View {
    @EnvironmentObject var appData: AppData
    
    @StateObject var scanner = Scanner()
    @State private var scannerCancellable: Cancellable? = nil
    
    var body: some View {
        NavigationView {
            List {
                ForEach(appData.devices) { device in
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
        .setBackgroundColor(.blue)
        .setSingleColumnNavigationViewStyle()
        .onAppear() {
            scannerCancellable = scanner.devicePublisher
                .throttle(for: 1.0, scheduler: RunLoop.main, latest: false)
                .sink(receiveCompletion: { result in
                    print(result)
                }, receiveValue: { device in
                    guard !appData.devices.contains(device) else { return }
                    appData.devices.append(device)
                })
        }
        .onDisappear() {
            scannerCancellable?.cancel()
        }
        .accentColor(.white)
    }
}

// MARK: - Preview

#if DEBUG
struct DeviceList_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            #if os(iOS)
            DeviceList()
                .environmentObject(ProjectList_Previews.previewAppData)
                .previewDevice("iPhone 12 mini")
            DeviceList()
                .preferredColorScheme(.dark)
                .environmentObject(ProjectList_Previews.previewAppData)
                .previewDevice("iPad Pro (12.9-inch) (4th generation)")
            #else
            DeviceList()
                .preferredColorScheme(.dark)
                .environmentObject(ProjectList_Previews.previewAppData)
            #endif
        }
    }
}
#endif
