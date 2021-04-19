//
//  DeviceData.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 15/04/2021.
//

import Foundation
import Combine
import os
import CoreBluetooth

final class DeviceData: NSObject, ObservableObject {
    
    // MARK: - API Properties
    
    @Published var isScanning = false
    @Published var scanResults: [Device] = []
    @Published var connectedDevices: [DeviceRemoteHandler] = []
    
    // MARK: - Private Properties
    
    private let logger = Logger(category: "DeviceData")
    
    private var deviceHandlers: [UUID: DeviceRemoteHandler] = [:]
    private lazy var bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    private var preferences = PreferencesData()
    
    private lazy var devicePublisher = PassthroughSubject<Device, BluetoothError>()
    private lazy var cancellables = Set<AnyCancellable>()
}

// MARK: - API

extension DeviceData {
    
    subscript(_ device: Device) -> DeviceRemoteHandler {
        guard let handler = deviceHandlers[device.id] else {
            let newHandler = DeviceRemoteHandler(device: device)
            deviceHandlers[device.id] = newHandler
            setupHandlerObservers(handler: newHandler)
            return newHandler
        }
        return handler
    }
    
    func toggle(with preferences: PreferencesData) {
        self.preferences = preferences
        if cancellables.isEmpty {
            setupDevicePublisher()
        }
        
        checkForBluetoothManagerErrors(in: bluetoothManager)
        isScanning.toggle()
        logger.debug("@isScanning toggled to: \(self.isScanning ? "On" : "Off")")
        switch isScanning {
        case true:
            guard bluetoothManager.state == .poweredOn else { break }
            let scanServices: [CBUUID]? = preferences.onlyScanUARTDevices ? [BluetoothManager.uartServiceId] : nil
            bluetoothManager.scanForPeripherals(withServices: scanServices, options: nil)
        case false:
            bluetoothManager.stopScan()
        }
    }
}

// MARK: - Private API

private extension DeviceData {
    
    private func setupDevicePublisher() {
        devicePublisher
            .throttle(for: 1.0, scheduler: RunLoop.main, latest: false)
            .sink(receiveCompletion: { result in
                print(result)
            }, receiveValue: { [weak self] in
                guard let self = self, !self.scanResults.contains($0) else { return }
                self.scanResults.append($0)
                self.logger.info("New Device found: \($0.name), UUID: \($0.id)")
            })
            .store(in: &cancellables)
    }
    
    private func setupHandlerObservers(handler: DeviceRemoteHandler) {
        handler.$device
            .drop(while: { (device) -> Bool in
                if case .notConnected = device.state {
                    return true
                } else {
                    return false
                }
            })
            .sink { [weak self] (device) in
                guard let `self` = self else { return }
                guard let index = self.scanResults.firstIndex(of: device) else { return }
                self.scanResults[index] = device
            }
            .store(in: &cancellables)
    }
}

// MARK: - CBCentralManagerDelegate

extension DeviceData: CBCentralManagerDelegate {
    private typealias R = RSSI
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
            let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
                ?? peripheral.name
                ?? "N/A"
        
        let device = Device(name: name, id: peripheral.identifier, rssi: R(value: RSSI.intValue), advertisementData: AdvertisementData(advertisementData))
        
        switch preferences.onlyScanConnectableDevices {
        case true:
            guard device.advertisementData.isConnectable == true else { return }
            fallthrough
        default:
            devicePublisher.send(device)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        checkForBluetoothManagerErrors(in: central)
    }
}

// MARK: - Private

private extension DeviceData {
    
    func checkForBluetoothManagerErrors(in central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            break
        default:
            guard isScanning else { return }
            isScanning = false
            logger.debug("Scanner Turned Off for State: \(central.state.debugDescription)")
            devicePublisher.send(completion: .failure(.bluetoothPoweredOff))
        }
    }
}
