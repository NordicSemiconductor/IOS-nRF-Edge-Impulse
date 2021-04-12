//
//  DeviceRemoteHandler.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 07/04/2021.
//

import Foundation
import Combine
import os

class DeviceRemoteHandler {
    private let logger = Logger(category: "DeviceRemoteHandler")
    
    let scanResult: ScanResult
    private var bluetoothManager: BluetoothManager!
    private var webSocketManager: WebSocketManager!
    private var cancelable = Set<AnyCancellable>()
    
    init(scanResult: ScanResult) {
        self.scanResult = scanResult
        bluetoothManager = BluetoothManager(peripheralId: scanResult.id)
    }
    
    deinit {
        cancelable.forEach { $0.cancel() }
    }
    
    func connect() {
        bluetoothManager.connect()
            .mapError( Error )
            .tryMap { try JSONDecoder().decode(HelloMessage.self, from: $0) }
            .flatMap { webSocketManager.connect() }
            
            
            .sink { [weak self] (completion) in
            switch (completion) {
            case .finished:
                self?.logger.info("BT Publisher finished")
            case .failure(let e):
                self?.logger.error("BT Publisher finished with error: \(e.localizedDescription)")
            }
        } receiveValue: { (data) in
            let str = String(data: data, encoding: .utf8)!
            Logger(category: "DeviceRemoteHandler").info("Got data from Bluetooth manager: \(str)")
        }
        .store(in: &cancelable)
    }
}
