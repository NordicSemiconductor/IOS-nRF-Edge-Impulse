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

class DeviceData: ObservableObject {
    @ObservedObject var appData: AppData
    @ObservedObject var scannerData: ScannerData
    @ObservedObject var registeredDevicesData: RegisteredDevicesData
    
    private var remoteHandlers: [DeviceRemoteHandler] = []
    
    @Published var filteredScanResults: [Device] = []
    @Published var registeredDevices: [RegisteredDevice] = []
    
    init(scannerData: ScannerData, registeredDevicesData: RegisteredDevicesData, appData: AppData) {
        self.scannerData = scannerData
        self.registeredDevicesData = registeredDevicesData
        self.appData = appData
        
        scannerData.turnOnBluetoothRadio()
    }
    
    func tryToConnect(scanResult: Device) {
        let handler = getRemoteHandler(for: scanResult)
        guard let keys = appData.selectedProject.map ({ appData.projectDevelopmentKeys[$0] }), let apiKey = keys?.apiKey else {
            return
        }
        
        handler.connect(apiKey: apiKey)
            .sink { completion in
                
            } receiveValue: { state in
                
            }

    }
    
    private func getRemoteHandler(for scanResult: Device) -> DeviceRemoteHandler {
        if let handler = remoteHandlers.first(where: { $0.id == scanResult.id }) {
            return handler
        } else {
            let newHandler = DeviceRemoteHandler(device: scanResult, registeredDeviceData: registeredDevicesData, appData: AppData())
            remoteHandlers.append(newHandler)
            return newHandler
        }
    }
}
