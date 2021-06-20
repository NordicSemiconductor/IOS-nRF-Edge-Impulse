//
//  DeviceData.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 01/06/2021.
//

import Foundation
import SwiftUI
import Combine
import os

extension DeviceData {
    struct RemoteDeviceWrapper {
        enum State {
            case notConnectable, readyToConnect, connected(DeviceRemoteHandler)
        }
        
        let device: RegisteredDevice
    }
    
    struct DeviceWrapper {
        enum State {
            case notConnected, connecting, connected
        }
        
        let device: Device
        var state: State
    }

    enum BluetoothStateError: Swift.Error {
        case poweredOff
        case unsupported
        case unknownState
        case unauthorized
    }
}

class DeviceData: ObservableObject {
    @ObservedObject var appData: AppData
    @ObservedObject var preferences = UserPreferences.shared
    
    let scanner: Scanner
    private lazy var logger = Logger(Self.self)
    private var registeredDeviceManager = RegisteredDevicesManager()
    private var remoteHandlers: [DeviceRemoteHandler] = []
    
    @Published fileprivate (set) var scanResults: [Device] = []
    @Published private (set) var registeredDevices: [RegisteredDevice] = []
    private (set) lazy var bluetoothStates = PassthroughSubject<Result<Bool, BluetoothStateError>, Never>()
    
    private var cancelables = Set<AnyCancellable>()
    
    init(scanner: Scanner = Scanner(), registeredDeviceManager: RegisteredDevicesManager = RegisteredDevicesManager(), appData: AppData) {
        self.scanner = scanner
        self.registeredDeviceManager = registeredDeviceManager
        self.appData = appData
        
        let settingsPublisher = preferences.$onlyScanConnectableDevices
            .removeDuplicates()
            .combineLatest(preferences.$onlyScanUARTDevices.removeDuplicates())
            .justDoIt { _ in
                self.scanResults.removeAll()
            }
                
        scanner.scan().combineLatest(settingsPublisher)
            .compactMap { (device, _) -> Device? in
                self.scanResults.contains(device) ? nil : device
            }
            .sink { device in
                self.scanResults.append(device)
            }
            .store(in: &cancelables)
        
        registeredDeviceManager.refreshDevices(appData: appData)
            .sink { completion in
                switch completion {
                case .finished:
                    self.logger.info("Fetch device completed")
                case .failure(let e):
                    self.logger.error("Fetch device failed. Error: \(e.localizedDescription)")
                }
            } receiveValue: { devices in
                self.registeredDevices = devices
            }
            .store(in: &cancelables)

    }
    
    func tryToConnect(scanResult: Device) {
        let handler = getRemoteHandler(for: scanResult)
        guard let keys = appData.selectedProject.map ({ appData.projectDevelopmentKeys[$0] }), let apiKey = keys?.apiKey else {
            return
        }
        
        handler.connect(apiKey: apiKey)
            .sink { completion in
                
            } receiveValue: { state in
                
            }
            .store(in: &cancelables)

    }
    
    func allConnectedAndReadyToUseDevices() -> [RegisteredDevice] {
        return []
    }
    
    func startSampling(_ viewState: DataAcquisitionViewState) {
        
    }
    
    private func getRemoteHandler(for scanResult: Device) -> DeviceRemoteHandler {
        if let handler = remoteHandlers.first(where: { $0.id == scanResult.id }) {
            return handler
        } else {
            let newHandler = DeviceRemoteHandler(device: scanResult, registeredDeviceManager: registeredDeviceManager, appData: appData)
            remoteHandlers.append(newHandler)
            return newHandler
        }
    }
}

#if DEBUG
extension Preview {
    // MARK: - ScannerData
    
    static let noDevicesScannerData: DeviceData = {
        let deviceData = DeviceData(scanner: Scanner(), registeredDeviceManager: RegisteredDevicesManager(), appData: AppData())
        deviceData.scanResults = []
        return deviceData
    }()
    
    static let isScanningButNoDevicesScannerData: DeviceData = {
        let scanner = Scanner()
        let deviceData = DeviceData(scanner: scanner, registeredDeviceManager: RegisteredDevicesManager(), appData: AppData())
        scanner.turnOnBluetoothRadio()
        deviceData.scanResults = []
        return deviceData
    }()

    static var mockScannerData: DeviceData = {
        let deviceData = DeviceData(scanner: Scanner(), registeredDeviceManager: RegisteredDevicesManager(), appData: AppData())
        deviceData.scanResults = [
            Device(name: "Device 1", id: UUID(), rssi: .good, advertisementData: .mock),
            Device(name: "Device 2", id: UUID(), rssi: .bad, advertisementData: .mock),
            Device(name: "Device 3", id: UUID(), rssi: .ok, advertisementData: .mock)
        ]
        return deviceData
    }()
}

#endif
