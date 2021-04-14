//
//  Scanner.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import Foundation
import Combine
import CoreBluetooth
import os

// MARK: - Scanner

final class Scanner: NSObject, ObservableObject {
    
    // MARK: - Private
    
    private lazy var bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    
    // MARK: - API Properties
    
    @Published var isScanning = false
    
    private(set) var devicePublisher = PassthroughSubject<DeviceRemoteHandler, BluetoothError>()
}

// MARK: - API

extension Scanner {
    
    func toggle() {
        checkForBluetoothManagerErrors()
        
        isScanning.toggle()
        switch isScanning {
        case true:
            guard bluetoothManager.state == .poweredOn else { break }
            bluetoothManager.scanForPeripherals(withServices: [BluetoothManager.uartServiceId], options: nil)
        case false:
            bluetoothManager.stopScan()
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension Scanner: CBCentralManagerDelegate {
    private typealias R = RSSI
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
            let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
                ?? peripheral.name
                ?? "N/A"
        
        let scanResult = ScanResult(name: name, id: peripheral.identifier, rssi: R(value: RSSI.intValue), advertisementData: AdvertisementData(advertisementData))
        
        if scanResult.advertisementData.isConnectable == true {
            let handler = DeviceRemoteHandler(scanResult: scanResult)
            devicePublisher.send(handler)
        }
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
            bluetoothManager.scanForPeripherals(withServices: [BluetoothManager.uartServiceId], options: nil)
        default:
            guard isScanning else { return }
            isScanning = false
            devicePublisher.send(completion: .failure(.bluetoothPoweredOff))
        }
    }
}
