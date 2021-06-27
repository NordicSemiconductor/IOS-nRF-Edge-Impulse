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
    struct RemoteDeviceWrapper: Identifiable, Hashable {
        let device: RegisteredDevice
        var id: Int { device.id }
        var state: State = .notConnectable
        
        enum State {
            case notConnectable, readyToConnect, connected
            
            var color: Color {
                switch self {
                case .notConnectable:
                    return .red
                case .readyToConnect:
                    return .orange
                case .connected:
                    return .green
                }
            }
        }
        
        static func ==(lhs: RemoteDeviceWrapper, rhs: RemoteDeviceWrapper) -> Bool {
            return lhs.device == rhs.device
        }
        
    }
    
    struct DeviceWrapper: Identifiable, Hashable {
        enum State {
            case notConnected, connecting, connected
        }
        
        let device: Device
        var state: State = .notConnected
        var id: UUID { device.id }
        
        static func ==(lhs: DeviceWrapper, rhs: DeviceWrapper) -> Bool {
            return lhs.device == rhs.device
        }
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
    
    @Published fileprivate (set) var scanResults: [DeviceWrapper] = []
    @Published private (set) var registeredDevices: [RemoteDeviceWrapper] = []
    
    private (set) lazy var bluetoothStates = PassthroughSubject<Result<Bool, BluetoothStateError>, Never>()
    
    var cancellables = Set<AnyCancellable>()
    
    init(scanner: Scanner = Scanner(), registeredDeviceManager: RegisteredDevicesManager = RegisteredDevicesManager(), appData: AppData) {
        self.scanner = scanner
        self.registeredDeviceManager = registeredDeviceManager
        self.appData = appData
        
        let settingsPublisher = preferences.$onlyScanConnectableDevices
            .removeDuplicates()
            .combineLatest(preferences.$onlyScanUARTDevices.removeDuplicates())
            .justDoIt { [weak self] _ in
                self?.scanResults.removeAll()
            }
                
        scanner.scan().combineLatest(settingsPublisher)
            .compactMap { [weak self] (device, _) -> DeviceWrapper? in
                let wrapper = DeviceWrapper(device: device)
                return (self?.scanResults.contains(wrapper)).flatMap { $0 ? nil : wrapper }
            }
            .sink { [weak self] device in
                self?.scanResults.append(device)
            }
            .store(in: &cancellables)
        
        refresh()
    }
    
    subscript (device: Device) -> DeviceRemoteHandler? {
        get {
            remoteHandlers.first(where: { $0.device == device })
        }
    }
    
    subscript (device: RegisteredDevice) -> DeviceRemoteHandler? {
        get {
            remoteHandlers.first(where: { $0.registeredDevice == device })
        }
    }
    
    func tryToConnect(scanResult: Device) {
        let handler = getRemoteHandler(for: scanResult)
        guard let keys = appData.selectedProject.map ({ appData.projectDevelopmentKeys[$0] }), let apiKey = keys?.apiKey else {
            return
        }
        
        if let index = scanResults.firstIndex(of: DeviceWrapper(device: scanResult)) {
            self.scanResults[index].state = .connecting
        }
        
        handler.connect(apiKey: apiKey)
            .sink { [logger] completion in
                logger.info("Device remote handler completed connection")
            } receiveValue: { [handler, logger, weak self] state in
                logger.info("Device remote handler obtained new state: \(state.debugDescription)")
                self?.stateChanged(of: handler, newState: state)
            }
            .store(in: &cancellables)
    }
    
    func disconnect(device: Device) {
        remoteHandlers
            .first(where: { $0.device == device })
            .map { self.disconnect(remoteHandler: $0) }
    }
    
    func disconnect(registeredDevice: RegisteredDevice) {
        remoteHandlers
            .first(where: { $0.registeredDevice != nil && $0.registeredDevice == registeredDevice })
            .map { self.disconnect(remoteHandler: $0) }
    }
    
    func disconnect(remoteHandler: DeviceRemoteHandler) {
        remoteHandler.disconnect()
        remoteHandlers.removeAll(where: { $0.device == remoteHandler.device })
        registeredDevices
            .firstIndex(where: { $0.device == remoteHandler.registeredDevice })
            .map { registeredDevices[$0].state = .readyToConnect }
        
        scanResults
            .firstIndex(where: { $0.device == remoteHandler.device })
            .map { scanResults[$0].state = .notConnected }
    }
    
    func allConnectedAndReadyToUseDevices() -> [DeviceRemoteHandler] {
        remoteHandlers.filter {
            if case .connected = $0.state {
                return true
            } else {
                return false
            }
        }
    }
    
    func refresh() {
        scanResults.removeAll()
        
        registeredDeviceManager.refreshDevices(appData: appData)
            .prefix(1)
            .sink { [logger] completion in
                switch completion {
                case .finished:
                    logger.info("Fetch device completed")
                case .failure(let e):
                    logger.error("Fetch device failed. Error: \(e.localizedDescription)")
                }
            } receiveValue: { [weak self] devices in
                self?.registeredDevices = devices
                    .map { device in
                        // TODO: add `readyToConnect` state
                        let state = self?.remoteHandlers
                            .first(where: { $0.registeredDevice == device })?.registeredDevice
                            .flatMap { d in self?.registeredDevices.first(where: { $0.device ==  d}) }
                            .map(\.state) ?? .notConnectable
                        
                        return RemoteDeviceWrapper(device: device, state: state)
                    }
            }
            .store(in: &cancellables)
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
    
    @discardableResult
    private func removeHandler(_ handler: DeviceRemoteHandler) -> Bool {
        remoteHandlers.firstIndex(of: handler)
            .map { remoteHandlers.remove(at: $0) } != nil
    }
    
    private func stateChanged(of handler: DeviceRemoteHandler, newState: DeviceRemoteHandler.ConnectionState) {
        if case .connected(let device, let remoteDevice) = newState {
            if let deviceIndex = self.scanResults.firstIndex(of: DeviceWrapper(device: device)) {
                self.scanResults[deviceIndex].state = .connected
            }
            
            if let deviceIndex = self.registeredDevices.firstIndex(of: RemoteDeviceWrapper(device: remoteDevice)) {
                self.registeredDevices[deviceIndex].state = .connected
            } else {
                self.registeredDevices.append(RemoteDeviceWrapper(device: remoteDevice, state: .connected))
            }
        } else if case .disconnected(let reason) = newState {
            
            if let deviceIndex = self.scanResults.firstIndex(of: DeviceWrapper(device: handler.device)) {
                self.scanResults[deviceIndex].state = .notConnected
            }
            
            switch reason {
            case .onDemand:
                break
            case .error(let e):
                AppEvents.shared.error = ErrorEvent(e)
            }
            
            self.removeHandler(handler)
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
        _ = scanner.turnOnBluetoothRadio()
        deviceData.scanResults = []
        return deviceData
    }()

    static var mockScannerData: DeviceData = {
        let deviceData = DeviceData(scanner: Scanner(), registeredDeviceManager: RegisteredDevicesManager(), appData: AppData())
        deviceData.scanResults = [
            Device(name: "Device 1", id: UUID(), rssi: .good, advertisementData: .mock),
            Device(name: "Device 2", id: UUID(), rssi: .bad, advertisementData: .mock),
            Device(name: "Device 3", id: UUID(), rssi: .ok, advertisementData: .mock)
        ].map { DeviceData.DeviceWrapper(device: $0) }
        return deviceData
    }()
}

#endif
