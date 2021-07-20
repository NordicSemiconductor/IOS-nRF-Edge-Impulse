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
    struct DeviceWrapper: Identifiable, Hashable {
        let device: Device
        var id: Int { device.id }
        var state: State = .notConnectable
        
        enum State {
            case notConnectable, readyToConnect, connecting, connected
            
            var color: Color {
                switch self {
                case .notConnectable:
                    return .red
                case .readyToConnect:
                    return .orange
                case .connected:
                    return .green
                case .connecting:
                    return .gray
                }
            }
        }
        
        static func ==(lhs: DeviceWrapper, rhs: DeviceWrapper) -> Bool {
            return lhs.device == rhs.device && lhs.device.name == rhs.device.name
        }
        
        static func ==(lhs: DeviceWrapper, rhs: ScanResult) -> Bool {
            return lhs.device.deviceId == rhs.id
        }
    }
    
    struct ScanResultWrapper: Identifiable, Hashable {
        enum State {
            case notConnected, connecting, connected
        }
        
        let scanResult: ScanResult
        var state: State = .notConnected
        var id: UUID { scanResult.uuid }
        var availableViaRegisteredDevices: Bool = false
        
        static func ==(lhs: ScanResultWrapper, rhs: ScanResultWrapper) -> Bool {
            return lhs.scanResult == rhs.scanResult
        }
        
        static func ==(lhs: ScanResultWrapper, rhs: Device) -> Bool {
            return lhs.scanResult.id == rhs.deviceId
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
    private var deviceManager = RegisteredDevicesManager()
    private var remoteHandlers: [DeviceRemoteHandler] = []
    
    @Published fileprivate (set) var scanResults: [ScanResultWrapper] = []
    @Published private (set) var registeredDevices: [DeviceWrapper] = []
    
    private (set) lazy var bluetoothStates = PassthroughSubject<Result<Bool, BluetoothStateError>, Never>()
    
    var cancellables = Set<AnyCancellable>()
    
    init(scanner: Scanner = Scanner(), registeredDeviceManager: RegisteredDevicesManager = RegisteredDevicesManager(), appData: AppData) {
        self.scanner = scanner
        self.deviceManager = registeredDeviceManager
        self.appData = appData
        
        let settingsPublisher = preferences.$onlyScanConnectableDevices
            .removeDuplicates()
            .combineLatest(preferences.$onlyScanUARTDevices.removeDuplicates())
            .justDoIt { [weak self] _ in
                self?.scanResults.removeAll()
            }
                
        scanner.scan().combineLatest(settingsPublisher)
            .compactMap { [weak self] (device, _) -> ScanResultWrapper? in
                let wrapper = ScanResultWrapper(scanResult: device)
                return (self?.scanResults.contains(wrapper)).flatMap { $0 ? nil : wrapper }
            }
            .sink { [weak self] device in
                self?.scanResults.append(device)
                self?.updateState(device.scanResult)
            }
            .store(in: &cancellables)
        
        refresh()
    }
    
    subscript (scanResult: ScanResult) -> DeviceRemoteHandler? {
        get {
            remoteHandlers.first(where: { $0.scanResult == scanResult })
        }
    }
    
    subscript (device: Device) -> DeviceRemoteHandler? {
        get {
            remoteHandlers.first(where: { $0.device == device })
        }
    }
    
    // MARK: Connecting
    func tryToConnect(scanResult: ScanResult) {
        let handler = getRemoteHandler(for: scanResult)
        guard let keys = appData.selectedProject.map ({ appData.projectDevelopmentKeys[$0] }), let apiKey = keys?.apiKey else {
            return
        }
        
        if let index = scanResults.firstIndex(of: ScanResultWrapper(scanResult: scanResult)) {
            self.scanResults[index].state = .connecting
        }
        
        if let index = associatedRegisteredDevice(with: scanResult).flatMap({ registeredDevices.firstIndex(of: $0 ) }) {
            registeredDevices[index].state = .connecting
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
    
    func tryToConnect(device: Device) {
        guard let scanResult = associatedScanResult(with: device)?.scanResult else {
            return
        }
        
        tryToConnect(scanResult: scanResult)
    }
    
    // MARK: Connection State
    func connectionState(of device: Device) -> DeviceWrapper.State? {
        registeredDevices.first(where: { $0.device == device })?.state
    }
    
    func connectionState(of scanResult: ScanResult) -> ScanResultWrapper.State? {
        scanResults.first(where: { $0.scanResult == scanResult })?.state
    }
    
    // MARK: Disconnect
    func disconnect(scanResult: ScanResult) {
        remoteHandlers
            .first(where: { $0.scanResult == scanResult })
            .map { self.disconnect(remoteHandler: $0) }
    }
    
    func disconnect(device: Device) {
        remoteHandlers
            .first(where: { $0.device != nil && $0.device == device })
            .map { self.disconnect(remoteHandler: $0) }
    }
    
    func disconnect(remoteHandler: DeviceRemoteHandler) {
        remoteHandler.disconnect()
        remoteHandlers.removeAll(where: { $0.scanResult == remoteHandler.scanResult })
        registeredDevices
            .firstIndex(where: { $0.device == remoteHandler.device })
            .map { registeredDevices[$0].state = .readyToConnect }
        
        scanResults
            .firstIndex(where: { $0.scanResult == remoteHandler.scanResult })
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
        
        deviceManager.refreshDevices(appData: appData)
            .sink { [logger] completion in
                switch completion {
                case .finished:
                    logger.info("Fetch device completed")
                case .failure(let e):
                    logger.error("Fetch device failed. Error: \(e.localizedDescription)")
                }
            } receiveValue: { [weak self] devices in
                guard let self = self else { return }
                self.registeredDevices = devices
                    .map { DeviceWrapper(device: $0, state: .notConnectable) }
                
                devices.forEach(self.updateState)
            }
            .store(in: &cancellables)
    }
    
    private func getRemoteHandler(for scanResult: ScanResult) -> DeviceRemoteHandler {
        if let handler = remoteHandlers.first(where: { $0 == scanResult }) {
            return handler
        } else {
            let newHandler = DeviceRemoteHandler(scanResult: scanResult, registeredDeviceManager: deviceManager, appData: appData)
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
        if case .connected(let device, let registeredDevice) = newState {
            if let deviceIndex = scanResults.firstIndex(of: ScanResultWrapper(scanResult: device)) {
                scanResults[deviceIndex].state = .connected
                scanResults[deviceIndex].availableViaRegisteredDevices = true
            }
            
            if let deviceIndex = registeredDevices.firstIndex(of: DeviceWrapper(device: registeredDevice)) {
                registeredDevices[deviceIndex].state = .connected
            } else {
                registeredDevices.append(DeviceWrapper(device: registeredDevice, state: .connected))
            }
        } else if case .disconnected(let reason) = newState {
            
            if let deviceIndex = self.scanResults.firstIndex(of: ScanResultWrapper(scanResult: handler.scanResult)) {
                scanResults[deviceIndex].state = .notConnected
            }
            
            if let registeredDeviceIndex = handler.device.flatMap({ registeredDevices.firstIndex(of: DeviceWrapper(device: $0)) }) {
                registeredDevices[registeredDeviceIndex].state = .readyToConnect
            } else if let registeredDeviceIndex = registeredDevices.firstIndex(where: { $0 == handler.scanResult }) {
                registeredDevices[registeredDeviceIndex].state = .readyToConnect
            }
            
            switch reason {
            case .onDemand:
                break
            case .error(let e):
                AppEvents.shared.error = ErrorEvent(e)
            }
            
            removeHandler(handler)
        }
    }
    
    private func updateState(_ scanResult: ScanResult) {
        guard let index = scanResults.firstIndex(where: { $0.scanResult == scanResult }) else {
            return
        }
        
        if let regDeviceIndex = registeredDevices.firstIndex(where: { $0 == scanResult }) {
            if case .notConnectable = registeredDevices[regDeviceIndex].state {
                registeredDevices[regDeviceIndex].state = .readyToConnect
            }
            
            scanResults[index].availableViaRegisteredDevices = true
        }
    }
    
    private func updateState(_ device: Device) {
        guard let regDeviceIndex = registeredDevices.firstIndex(where: { $0.device == device }) else {
            return
        }
        
        registeredDevices[regDeviceIndex].state = remoteHandlers
            .first(where: { $0.device == device })
            .flatMap { h -> DeviceWrapper.State? in
                switch h.state {
                case .connecting: return .connecting
                case .connected: return .connected
                default: return nil
                }
            }
            ?? associatedScanResult(with: device)
            .map { _ in DeviceWrapper.State.readyToConnect}
        ?? .notConnectable
        
        if let scanResultIndex = scanResults.firstIndex(where: { $0 == device }) {
            scanResults[scanResultIndex].availableViaRegisteredDevices = true
        }
    }
    
    // TODO: Chose connect method for searching associated devices
    private func associatedScanResult(with device: Device) -> ScanResultWrapper? {
        scanResults.first { $0 == device }
    }
    
    private func associatedRegisteredDevice(with scanResult: ScanResult) -> DeviceWrapper? {
        registeredDevices.first { $0 == scanResult }
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
            ScanResult(name: "Device 1", uuid: UUID(), rssi: .good, advertisementData: .mock),
            ScanResult(name: "Device 2", uuid: UUID(), rssi: .bad, advertisementData: .mock),
            ScanResult(name: "Device 3", uuid: UUID(), rssi: .ok, advertisementData: .mock)
        ].map { DeviceData.ScanResultWrapper(scanResult: $0) }
        return deviceData
    }()
}

#endif
