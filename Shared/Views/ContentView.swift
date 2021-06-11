//
//  ContentView.swift
//  Shared
//
//  Created by Dinesh Harjani on 22/02/2021.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var resourceData: ResourceData
    @ObservedObject var deviceData: DeviceData
    
    var body: some View {
        if appData.isLoggedIn {
            LoggedInRootView()
                .onAppear() {
                    resourceData.load()
                }
                .environmentObject(deviceData)
        } else {
            NativeLoginView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(deviceData: DeviceData(scannerData: ScannerData(), registeredDevicesData: RegisteredDevicesData(), appData: AppData()))
            .environmentObject(AppData())
    }
}
#endif
