//
//  Scanner.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import Foundation
import Combine
import CoreBluetooth

// MARK: - Scanner

final class Scanner: NSObject, ObservableObject {
    
    // MARK: - Private
    
    private lazy var bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    
    // MARK: - API Properties
    
    @Published var isScanning = false
    
    private(set) var devicePublisher = PassthroughSubject<Device, BluetoothError>()
}

// MARK: - API

extension Scanner {
    
    func toggle() {
        checkForBluetoothManagerErrors()
        
        isScanning.toggle()
        switch isScanning {
        case true:
            guard bluetoothManager.state == .poweredOn else { break }
            bluetoothManager.scanForPeripherals(withServices: nil, options: nil)
        case false:
            bluetoothManager.stopScan()
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension Scanner: CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        devicePublisher.send(Device(id: peripheral.identifier))
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        checkForBluetoothManagerErrors()
    }
}

// MARK: - Private

private extension Scanner {
    
    func checkForBluetoothManagerErrors() {
        switch bluetoothManager.state {
        case .poweredOn:
            guard isScanning else { return }
            bluetoothManager.scanForPeripherals(withServices: nil, options: nil)
        default:
            guard isScanning else { return }
            isScanning = false
            devicePublisher.send(completion: .failure(.bluetoothPoweredOff))
        }
    }
}
