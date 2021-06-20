//
//  Scanner.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 15/04/2021.
//

import SwiftUI
import Combine
import os
import CoreBluetooth

final class Scanner: NSObject {
    // MARK: - Private Properties
    
    private lazy var logger = Logger(Self.self)
    private lazy var bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    private (set) lazy var devicePublisher = PassthroughSubject<Device, Never>()
    
    @Published private (set) var managerState: CBManagerState = .unknown
    
    @Published private var shouldScan = false
    @Published private (set) var isScanning = false
    
    let userPreferences: UserPreferences
    private var cancellable = Set<AnyCancellable>()
        
    init(userPreferences: UserPreferences = .shared) {
        self.userPreferences = userPreferences
        super.init()
    }
}

// MARK: - API

extension Scanner {
    
    /**
     Needs to be called before any attempt to Scan is made.
     
     The first call to `CBCentralManager.state` is the one that turns on the BLE Radio if it's available, and successive calls check whether it turned on or not, but they cannot be made one after the other or the second will return an error. This is why we make this first call ahead of time.
     */
    func turnOnBluetoothRadio() -> AnyPublisher<CBManagerState, Never> {
        shouldScan = true
        _ = bluetoothManager.state
        return $managerState.eraseToAnyPublisher()
    }
    
    func toggle() {
        shouldScan.toggle()
    }
    
    func scan() -> AnyPublisher<Device, Never> {
        turnOnBluetoothRadio()
            .filter { $0 == .poweredOn }
            .combineLatest($shouldScan, userPreferences.$onlyScanUARTDevices)
            .flatMap { (_, isScanning, onlyUART) -> PassthroughSubject<Device, Never> in
                if isScanning {
                    let scanServices = onlyUART ? [BluetoothManager.uartServiceId] : nil
                    self.bluetoothManager.scanForPeripherals(withServices: scanServices,
                                                        options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                    self.isScanning = true
                } else {
                    self.bluetoothManager.stopScan()
                    self.isScanning = false
                }
                
                return self.devicePublisher
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - CBCentralManagerDelegate

extension Scanner: CBCentralManagerDelegate {
    private typealias R = RSSI
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = Device(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
//        logger.info("New device discovered: \(device.name)")
        
        if userPreferences.onlyScanConnectableDevices {
            if device.advertisementData.isConnectable == true {
                devicePublisher.send(device)
            }
        } else {
            devicePublisher.send(device)
        }
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        managerState = central.state
        
        logger.info("Bluetooth changed state: \(central.state)")
        
        if central.state != .poweredOn {
            shouldScan = false
        }
    }
}
