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
    @EnvironmentObject var preferencesData: PreferencesData
    
    @StateObject var scanner = Scanner()
    @State private var scannerCancellable: Cancellable? = nil
    
    var body: some View {
        List {
            ForEach(appData.scanResults) { device in
                NavigationLink(destination: DeviceDetails(scanResult: device)) {
                    DeviceRow(device: device)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(scanner.isScanning ? "Stop Scanning" : "Start Scanning") {
                    scanner.toggle(with: preferencesData)
                }
            }
        }
        .onAppear() {
            scannerCancellable = scanner.devicePublisher
                .throttle(for: 1.0, scheduler: RunLoop.main, latest: false)
                .sink(receiveCompletion: { result in
                    print(result)
                }, receiveValue: { device in
                    guard !appData.scanResults.contains(device) else { return }
                    appData.scanResults.append(device)
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
        #if os(OSX)
        Group {
            DeviceList()
                .setTitle("Devices")
                .environmentObject(Preview.projectsPreviewAppData)
        }
        #elseif os(iOS)
        Group {
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .environmentObject(Preview.projectsPreviewAppData)
                    .previewDevice("iPhone 12 mini")
            }
            .setBackgroundColor(Assets.blue)
            
            NavigationView {
                DeviceList()
                    .setTitle("Devices")
                    .preferredColorScheme(.dark)
                    .environmentObject(Preview.projectsPreviewAppData)
                    .previewDevice("iPad Pro (12.9-inch) (4th generation)")
            }
            .setBackgroundColor(Assets.blue)
        }
        #endif
    }
}
#endif
