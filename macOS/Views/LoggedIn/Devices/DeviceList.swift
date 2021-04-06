//
//  DeviceList.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 26/3/21.
//

import SwiftUI
import Combine

struct DeviceList: View {
    
    @EnvironmentObject var appData: AppData
    
    @StateObject var scanner = Scanner()
    @State private var scannerCancellable: Cancellable? = nil
    
    var body: some View {
        List {
            ForEach(appData.scanResults) { device in
                DeviceRow(device: device)
            }
        }
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
        Group {
            DeviceList()
                .preferredColorScheme(.dark)
                .environmentObject(Preview.projectsPreviewAppData)
        }
    }
}
#endif
