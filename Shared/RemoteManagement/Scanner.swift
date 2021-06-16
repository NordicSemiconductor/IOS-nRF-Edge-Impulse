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
    @Published private (set) var isScunning = false
    
    let userPreferences: UserPreferences
    private var cancellable = Set<AnyCancellable>()
        
    init(userPreferences: UserPreferences = .shared) {
        self.userPreferences = userPreferences
        super.init()
        
        userPreferences.$onlyScanUARTDevices.removeDuplicates()
            .sink { _ in
                
            } receiveValue: { _ in
                self.refreshScanning()
            }
            .store(in: &cancellable)

    }
}

// MARK: - API

extension Scanner {
    
    /**
     Needs to be called before any attempt to Scan is made.
     
     The first call to `CBCentralManager.state` is the one that turns on the BLE Radio if it's available, and successive calls check whether it turned on or not, but they cannot be made one after the other or the second will return an error. This is why we make this first call ahead of time.
     */
    func turnOnBluetoothRadio() {
        _ = bluetoothManager.state
    }
    
    func toggle() {
        if bluetoothManager.isScanning {
            bluetoothManager.stopScan()
        } else {
            refreshScanning()
        }
    }
    
    func refreshScanning() {
        bluetoothManager.stopScan()
        let scanServices = userPreferences.onlyScanUARTDevices ? [BluetoothManager.uartServiceId] : nil
        startScanning(scanServices: scanServices)
    }
    
    private func startScanning(scanServices: [CBUUID]?) {
        bluetoothManager.scanForPeripherals(withServices: scanServices,
                                            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        isScunning = true
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
        
        if central.state != .poweredOn {
            isScunning = false
        }
    }
}
