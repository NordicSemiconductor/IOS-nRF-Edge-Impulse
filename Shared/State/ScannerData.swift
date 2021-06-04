//
//  ScannerData.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 15/04/2021.
//

import SwiftUI
import Combine
import os
import CoreBluetooth

final class ScannerData: NSObject, ObservableObject {
    
    // MARK: - API Properties
    
    @Published var isScanning = false
    @Published var scanResults: [Device] = []
    @Published var connectedDevices: [DeviceRemoteHandler] = []
    
    @ObservedObject var preferences = UserPreferences.shared
    
    // MARK: - Private Properties
    
    private lazy var logger = Logger(Self.self)
    
    private var deviceHandlers: [UUID: DeviceRemoteHandler] = [:]
    private lazy var bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    private lazy var devicePublisher = PassthroughSubject<Device, BluetoothError>()
    private lazy var cancellables = Set<AnyCancellable>()
}

// MARK: - API

extension ScannerData {
    
    subscript(_ device: Device) -> DeviceRemoteHandler {
        guard let handler = deviceHandlers[device.id] else {
            let newHandler = DeviceRemoteHandler(device: device)
            deviceHandlers[device.id] = newHandler
            setupHandlerObservers(handler: newHandler)
            return newHandler
        }
        return handler
    }
    
    func allConnectedAndReadyToUseDevices() -> [Device] {
        scanResults.filter(\.isConnectedAndReadyForUse)
    }
    
    func allOtherDevices() -> [Device] {
        scanResults.inverseFilter(\.isConnectedAndReadyForUse)
    }
    
    /**
     Needs to be called before any attempt to Scan is made.
     
     The first call to `CBCentralManager.state` is the one that turns on the BLE Radio if it's available, and successive calls check whether it turned on or not, but they cannot be made one after the other or the second will return an error. This is why we make this first call ahead of time.
     */
    func turnOnBluetoothRadio() {
        _ = bluetoothManager.state
    }
    
    func toggle() {
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
            bluetoothManager.scanForPeripherals(withServices: scanServices,
                                                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case false:
            bluetoothManager.stopScan()
        }
    }
    
    func startSampling(_ viewState: DataAcquisitionViewState) {
        guard let newSampleMessage = viewState.newSampleMessage() else { return }
        viewState.isSampling = true
        do {
            let deviceHandler = self[viewState.selectedDevice]
            try deviceHandler.sendSampleRequest(newSampleMessage)
        }
        catch (let error) {
            viewState.isSampling = false
            AppEvents.shared.error = ErrorEvent(error)
        }
    }
}

// MARK: - Private API

private extension ScannerData {
    
    private func setupDevicePublisher() {
        devicePublisher
            .throttle(for: 1.0, scheduler: RunLoop.main, latest: false)
            .sink(receiveCompletion: { result in
                print(result)
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                if let index = self.scanResults.firstIndex(of: $0) {
                    self.scanResults[index] = $0
                } else {
                    self.scanResults.append($0)
                    self.logger.info("New Device found: \($0.name), UUID: \($0.id)")
                }
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

extension ScannerData: CBCentralManagerDelegate {
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

private extension ScannerData {
    
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
