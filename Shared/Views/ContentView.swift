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
    @EnvironmentObject var deviceData: DeviceData
    
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
        let appData = AppData()
        ContentView()
            .environmentObject(appData)
            .environmentObject(DeviceData(scanner: Scanner(), registeredDeviceManager: RegisteredDevicesManager(), appData: appData))
    }
}
#endif
