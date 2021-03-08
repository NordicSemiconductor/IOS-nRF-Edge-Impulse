//
//  Scanner.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import Foundation
import CoreBluetooth

// MARK: - Scanner

final class Scanner: NSObject, ObservableObject {
    
    // MARK: - Private
    
    private lazy var bluetoothManager = CBCentralManager(delegate: self, queue: .global(qos: .userInitiated))
    
    // MARK: - API Properties
    
    @Published var isScanning = false {
        didSet {
            toggle()
        }
    }
    @Published var scannedDevices: [Device] = []
}

// MARK: - API

extension Scanner {
    
    func toggle() {
        switch isScanning {
        case true:
            bluetoothManager.scanForPeripherals(withServices: nil, options: nil)
        case false:
            bluetoothManager.stopScan()
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension Scanner: CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let device = Device(id: peripheral.identifier)
        guard !scannedDevices.contains(device) else { return }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
}
