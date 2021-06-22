//
//  DataContainer.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/6/21.
//

import Foundation

final class DataContainer: ObservableObject {
    let appData = AppData()
    let resourceData = ResourceData()
    lazy var deiceData = DeviceData(appData: self.appData)
}
