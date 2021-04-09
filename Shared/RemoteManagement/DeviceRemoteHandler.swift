//
//  DeviceRemoteHandler.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 07/04/2021.
//

import Foundation
import Combine

class DeviceRemoteHandler {
    
    private let scanResult: ScanResult
    private var bluetoothManager: BluetoothManager!
    private var webSocketManager: WebSocketManager!
    private var cancelable = Set<AnyCancellable>()
    
    init(scanResult: ScanResult) {
        self.scanResult = scanResult
    }
    
    deinit {
        // TODO: Disconnect the device
    }
    
    func connect() {
        bluetoothManager = BluetoothManager(peripheralId: scanResult.id)
        bluetoothManager.connect().sink { (completion) in
            switch (completion) {
            case .finished: break
            case .failure(let e):
                print(e.localizedDescription)
            }
        } receiveValue: { (data) in
            
        }
        .store(in: &cancelable)

        

    }
}
