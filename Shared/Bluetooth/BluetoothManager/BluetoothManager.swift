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
import McuManager

/// Static methods and nested structures
extension BluetoothManager {
    struct Error: Swift.Error {
        let localizedDescription: String
        
        static let cantRetreivePeripheral = Error(localizedDescription: "Can't retreive the peripheral.")
        static let failedToConnect = Error(localizedDescription: "Failed to connect to the peripheral")
    }
    
    enum State {
        case notConnected, connecting, connected, disconnected, readyToUse
    }
    
    static let uartServiceId = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static let txCharacteristicId = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    static let rxCharacteristicId = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
}

/// `BluetoothManager` is responsible for connection and managing peripheral connection
/// Each `BluetoothManager` can handle only one peripheral
final class BluetoothManager: NSObject, ObservableObject {
    
    // MARK: - Private Properties
    
    private let centralManager: CBCentralManager
    
    private let transmissionSubject = PassthroughSubject<Data, Never>()
    let receptionSubject = PassthroughSubject<Data, Never>()
    
    @Published var state: State = .notConnected
    private var btStateSubject = PassthroughSubject<CBManagerState, Swift.Error>()
    
    private let logger = Logger(category: "BluetoothManager")
    
    private var pId: UUID
    private var peripheral: CBPeripheral!
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    
    private var cancellables = Set<AnyCancellable>()
    
    init(peripheralId: UUID) {
        self.centralManager = CBCentralManager()
        self.pId = peripheralId
        super.init()
        
        centralManager.delegate = self
        transmissionSubject.sinkOrRaiseAppEventError { [weak self] data in
            guard let self = self else { return }
            self.peripheral.writeValue(data, for: self.txCharacteristic, type: .withResponse)
        }
        .store(in: &cancellables)
    }
    
    func connect() -> AnyPublisher<State, Swift.Error> {
        return btStateSubject.drop(while: { $0 != .poweredOn })
            .flatMap { _ -> AnyPublisher<State, Swift.Error> in
                do {
                    try self.tryToConnect()
                } catch let e {
                    return Fail(error: e).eraseToAnyPublisher()
                }
                return self.$state.setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func write<T: Codable>(_ data: T) throws {
        guard let encodedData = try? JSONEncoder().encode(data) else { return }
        transmissionSubject.send(encodedData)
    }
    
    func sendUpgradeFirmware(_ data: Data, logDelegate: McuMgrLogDelegate,
                             firmwareDelegate: FirmwareUpgradeDelegate) throws {
        let bleTransport = McuMgrBleTransport(peripheral)
        bleTransport.logDelegate = logDelegate
        let dfuManager = FirmwareUpgradeManager(transporter: bleTransport, delegate: firmwareDelegate)

        // Start the firmware upgrade with the image data
        try dfuManager.start(data: data)
    }
    
    func disconnect() {
        guard let peripheral = peripheral else {
            logger.debug("Peripheral for Device \(self.pId.uuidString) is nil.")
            return
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    private func tryToConnect() throws {
        self.state = .connecting
        
        guard let p = centralManager.retrievePeripherals(withIdentifiers: [pId]).first else {
            throw Error.cantRetreivePeripheral
        }
        
        peripheral = p
        peripheral.delegate = self
        centralManager.connect(p, options: nil)
    }
    
    #if DEBUG
    // TODO: Remove once we stop mocking firmware responses.
    internal func mockFirmwareResponse<T: Codable>(_ item: T) {
        let data: Data! = try? JSONEncoder().encode(item)
        received(data)
    }
    #endif
    
    private func received(_ data: Data) {
        #if DEBUG
        if let stringData = String(data: data, encoding: .utf8) {
            logger.debug("Received Data: \(stringData)")
        }
        #endif
        receptionSubject.send(data)
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
        
        service.characteristics?.forEach {
            switch $0.uuid {
            case Self.txCharacteristicId:
                txCharacteristic = $0
                peripheral.setNotifyValue(true, for: txCharacteristic)
                logger.info("TX Characteristic discovered")
            case Self.rxCharacteristicId:
                rxCharacteristic = $0
                logger.info("RX Characteristic discovered")
            default:
                break
            }
        }
        
        guard txCharacteristic != nil, rxCharacteristic != nil else { return }
        state = .readyToUse
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Swift.Error?) {
        logger.info("Notification status has been updated: \(characteristic.isNotifying) for characteristic: \(characteristic)")
        if let e = error {
            logger.error("Error: \(e.localizedDescription)")
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
        
        received(bytesReceived)
        
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
        btStateSubject.send(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.info("Connected the peripheral: \(peripheral.identifier.uuidString)")
        self.state = .connected
        self.peripheral.discoverServices([Self.uartServiceId])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Swift.Error?) {
        logger.info("Did fail to connect the peripheral: \(peripheral.identifier.uuidString)")
        logger.error("Error: \(error?.localizedDescription ?? "")")
        let e: Swift.Error = error ?? Error.failedToConnect
        btStateSubject.send(completion: .failure(e))
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Swift.Error?) {
        logger.info("Did disconnect peripheral: \(peripheral)")
        error.map { logger.error("Did disconnect error: \($0.localizedDescription)") }
        self.peripheral = nil
        
        if let e = error {
            btStateSubject.send(completion: .failure(e))
        } else {
            btStateSubject.send(completion: .finished)
        }
    }
}
