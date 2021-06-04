//
//  BluetoothData.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 01/06/2021.
//

import Foundation
import SwiftUI

struct DeviceWrapper {
    enum State {
        case notConnectable, readyToConnect, connected(DeviceRemoteHandler)
    }
    
    let device: RegisteredDevice
}

class DevicesManager {
    @ObservedObject var scannerData: ScannerData
    @ObservedObject var registeredDevicesData: RegisteredDevicesData
    
    @Published var remoteHandlers: [DeviceRemoteHandler] = []
    
    @Published var filteredScanResults: [Device] = []
    @Published var registeredDevices: [RegisteredDevice] = []
    
    init(scannerData: ScannerData, registeredDevicesData: RegisteredDevicesData) {
        self.scannerData = scannerData
        self.registeredDevicesData = registeredDevicesData
        
        
    }
}
