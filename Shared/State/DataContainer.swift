//
//  DataContainer.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/6/21.
//

import Foundation

final class DataContainer: ObservableObject {
    
    let appData: AppData
    let deviceData: DeviceData
    
    init() {
        let appData = AppData()
        self.appData = appData
        self.deviceData = DeviceData(appData: appData)
    }
}
