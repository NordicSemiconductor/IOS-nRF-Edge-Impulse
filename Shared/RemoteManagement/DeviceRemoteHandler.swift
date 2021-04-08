//
//  DeviceRemoteHandler.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 07/04/2021.
//

import Foundation

class DeviceRemoteHandler {
    
    private let scanResult: ScanResult
    private var bluetoothManager: BluetoothManager!
    private var webSocketManager: WebSocketManager!
    
    init(scanResult: ScanResult) {
        self.scanResult = scanResult
    }
    
    deinit {
        // TODO: Disconnect the device
    }
    
    func connect() {
        bluetoothManager = BluetoothManager(peripheralId: scanResult.id)
        do {
            try bluetoothManager.connect()
            bluetoothManager.objectWillChange.sink { [weak self] in
                self?.stateChanged()
            }
        } catch let e {
            
        }
    }
}

extension DeviceRemoteHandler {
    private func stateChanged() {
        switch bluetoothManager.state {
        case .readyToConnect:
            try! bluetoothManager.connect()
        case .readyToUse:
            // TODO: listen for TX Messages
            break
        default:
            break 
        }
    }
}
