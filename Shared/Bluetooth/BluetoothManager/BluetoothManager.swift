//
//  BluetoothManager.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 24/03/2021.
//

import Foundation
import CoreBluetooth
import os

/// `BluetoothManager` is responsible for connection and managing peripheral connection
/// Each `BluetoothManager` can handle only one peripheral
final class BluetoothManager: NSObject {
    
    struct BluetoothManagerError: Error {
        static let cantRetreivePeripheral = BluetoothManagerError()
    }
    
    private let uartServiceId = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    private let txCharacteristicId = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    private let rxCharacteristicId = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    
    private var pId: UUID
    
    let centralManager: CBCentralManager
    
    private var peripheral: CBPeripheral!
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    private var timer: Timer!
    
    init(peripheralId: UUID) {
        self.centralManager = CBCentralManager()
        self.pId = peripheralId
        super.init()
        
        centralManager.delegate = self
    }
    
    func connect() throws {
        guard let p = centralManager.retrievePeripherals(withIdentifiers: [pId]).first else {
            throw BluetoothManagerError.cantRetreivePeripheral
        }
        
        peripheral = p
        peripheral?.delegate = self 
        centralManager.connect(p, options: nil)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?
            .filter { $0.uuid == uartServiceId }
            .forEach { peripheral.discoverCharacteristics(nil, for: $0) }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        service.characteristics?
            .forEach {
                if $0.uuid == txCharacteristicId {
                    txCharacteristic = $0
                    peripheral.setNotifyValue(true, for: txCharacteristic)
                } else if $0.uuid == rxCharacteristicId {
                    rxCharacteristic = $0
                }
                
                if case .some = txCharacteristic, case .some = rxCharacteristic {
                    
                }
            }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard case .none = error else {
            // TODO: Log error
            return
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            peripheral.discoverServices([uartServiceId])
        }
    }
    
}
