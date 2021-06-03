//
//  BluetoothData.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 01/06/2021.
//

import Foundation
import SwiftUI

class DevicesManager {
    @ObservedObject var scannerData: ScannerData
    @Published var remoteHandlers: [DeviceRemoteHandler] = []
    @Published var registeredDevices: [RegisteredDevice] = []
    
    init(scannerData: ScannerData) {
        self.scannerData = scannerData
    }
}
