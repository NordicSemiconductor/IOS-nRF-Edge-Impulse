//
//  BluetoothManager.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 24/03/2021.
//

import Foundation
import CoreBluetooth
import os

/// Static methods and nested structures
extension BluetoothManager {
    struct BluetoothManagerError: Error {
        static let cantRetreivePeripheral = BluetoothManagerError()
    }
    
    static let uartServiceId = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static let txCharacteristicId = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    static let rxCharacteristicId = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
}

/// `BluetoothManager` is responsible for connection and managing peripheral connection
/// Each `BluetoothManager` can handle only one peripheral
final class BluetoothManager: NSObject {
    
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
        if let e = error {
            Logger().error("Failed to dicover services. Error: \(e.localizedDescription)")
            return
        }
        
        peripheral.services?
            .filter { $0.uuid == Self.uartServiceId }
            .forEach {
                Logger().info("Did discovered service: \($0.uuid.uuidString)")
                peripheral.discoverCharacteristics(nil, for: $0)
            }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let e = error {
            Logger().error("Failed to discover characteristic. Error: \(e.localizedDescription)")
        }
        
        service.characteristics?
            .forEach {
                
                if $0.uuid == Self.txCharacteristicId {
                    txCharacteristic = $0
                    peripheral.setNotifyValue(true, for: txCharacteristic)
                    Logger().info("TX Characteristic discovered")
                } else if $0.uuid == Self.rxCharacteristicId {
                    rxCharacteristic = $0
                    Logger().info("RX Characteristic discovered")
                }
                
                if case .some = txCharacteristic, case .some = rxCharacteristic {
                    // TODO: Start workflow
                }
            }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            Logger().warning("Updating characteristic has failed")
            Logger().error("\(e.localizedDescription)")
            return
        }
        
        guard let bytesReceived = characteristic.value else {
            Logger().info("Notification received from: \(characteristic.uuid.uuidString), with empty value")
            Logger().error("Empty packet received")
            return
        }
        
        if let validUTF8String = String(data: bytesReceived, encoding: .utf8) {
            Logger().debug("Received new data: \(validUTF8String)")
        } else {
            Logger().debug("Received string can't be parsed")
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Logger().info("Central Manager state changed to \(central.state)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Logger().info("Connected the peripheral: \(peripheral.identifier.uuidString)")
        if peripheral == self.peripheral {
            peripheral.discoverServices([Self.uartServiceId])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Logger().info("Did fail to connect the peripheral: \(peripheral.identifier.uuidString)")
        Logger().error("Error: \(error?.localizedDescription ?? "")")
    }
    
}

extension CBManagerState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .resetting:
            return "Resetting"
        case .unsupported:
            return "Unsupported"
        case .unauthorized:
            return "Unauthorized"
        case .poweredOff:
            return "Off"
        case .poweredOn:
            return "On"
        case .unknown:
            fallthrough
        @unknown default:
            return "Unknown"
        }
    }
}
