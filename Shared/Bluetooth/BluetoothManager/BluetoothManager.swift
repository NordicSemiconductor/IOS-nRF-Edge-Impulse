//
//  BluetoothManager.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 24/03/2021.
//

import Foundation
import CoreBluetooth
import os
import Combine

/// Static methods and nested structures
extension BluetoothManager {
    struct Error: Swift.Error {
        let localizedDescription: String
        
        static let cantRetreivePeripheral = Error(localizedDescription: "Can't retreive the peripheral.")
    }
    
    static let uartServiceId = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static let txCharacteristicId = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    static let rxCharacteristicId = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
}

/// `BluetoothManager` is responsible for connection and managing peripheral connection
/// Each `BluetoothManager` can handle only one peripheral
final class BluetoothManager: NSObject, ObservableObject {
    
    let centralManager: CBCentralManager
    
    private let publisher = PassthroughSubject<Data, Error>()
    private let logger = Logger(category: "BluetoothManager")
    
    private var pId: UUID
    private var peripheral: CBPeripheral!
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    
    // Throw en error if the peripheral was not connected or required characteristics were not found, or data was not received after timeout.
    private var timer: Timer!
    
    init(peripheralId: UUID) {
        self.centralManager = CBCentralManager()
        self.pId = peripheralId
        super.init()
        
        centralManager.delegate = self
    }
    
    func connect() -> AnyPublisher<Data, Error> {
        guard let p = centralManager.retrievePeripherals(withIdentifiers: [pId]).first else {
            return Result.Publisher(.failure(Error.cantRetreivePeripheral)).eraseToAnyPublisher()
        }
        
        peripheral = p
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
        
        return publisher.eraseToAnyPublisher()
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Swift.Error?) {
        if let e = error {
            logger.error("Failed to dicover services. Error: \(e.localizedDescription)")
            return
        }
        
        peripheral.services?
            .filter { $0.uuid == Self.uartServiceId }
            .forEach {
                logger.info("Did discovered service: \($0.uuid.uuidString)")
                peripheral.discoverCharacteristics(nil, for: $0)
            }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Swift.Error?) {
        
        if let e = error {
            logger.error("Failed to discover characteristic. Error: \(e.localizedDescription)")
        }
        
        service.characteristics?
            .forEach {
                
                if $0.uuid == Self.txCharacteristicId {
                    txCharacteristic = $0
                    peripheral.setNotifyValue(true, for: txCharacteristic)
                    logger.info("TX Characteristic discovered")
                } else if $0.uuid == Self.rxCharacteristicId {
                    rxCharacteristic = $0
                    logger.info("RX Characteristic discovered")
                }
                
                if case .some = txCharacteristic, case .some = rxCharacteristic {
                    let mockMsh = ResponseRootObject.mock
                    let data = try! JSONEncoder().encode(mockMsh)
                    publisher.send(data)
                }
            }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Swift.Error?) {
        if let e = error {
            logger.warning("Updating characteristic has failed")
            logger.error("\(e.localizedDescription)")
            return
        }
        
        guard let bytesReceived = characteristic.value else {
            logger.info("Notification received from: \(characteristic.uuid.uuidString), with empty value")
            logger.error("Empty packet received")
            return
        }
        
        publisher.send(bytesReceived)
        
        if let validUTF8String = String(data: bytesReceived, encoding: .utf8) {
            logger.debug("Received new data: \(validUTF8String)")
        } else {
            logger.debug("Received string can't be parsed")
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.info("Central Manager state changed to \(central.state)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.info("Connected the peripheral: \(peripheral.identifier.uuidString)")
        
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.peripheral.discoverServices([Self.uartServiceId])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Swift.Error?) {
        logger.info("Did fail to connect the peripheral: \(peripheral.identifier.uuidString)")
        logger.error("Error: \(error?.localizedDescription ?? "")")
        
    }
    
}
