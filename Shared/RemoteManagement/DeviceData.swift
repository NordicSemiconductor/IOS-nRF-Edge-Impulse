//
//  DeviceData.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 01/06/2021.
//

import Foundation
import SwiftUI
import Combine


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
    private var registeredDeviceManager = RegisteredDevicesManager()
    private var remoteHandlers: [DeviceRemoteHandler] = []
    
    @Published fileprivate (set) var scanResults: [Device] = []
    @Published private (set) var registeredDevices: [RegisteredDevice] = []
    private (set) lazy var bluetoothStates = PassthroughSubject<Result<Bool, BluetoothStateError>, Never>()
    
    private var cancelables = Set<AnyCancellable>()
    
    init(scanner: Scanner, registeredDeviceManager: RegisteredDevicesManager, appData: AppData) {
        self.scanner = scanner
        self.registeredDeviceManager = registeredDeviceManager
        self.appData = appData
        
        scanner.turnOnBluetoothRadio()
        
        scanner.$managerState
            .combineLatest(scanner.$isScunning)
            .map { (state, scanning) -> Result<Bool, BluetoothStateError> in
                switch state {
                case .poweredOn:
                    return .success(scanning)
                case .poweredOff:
                    return .failure(.poweredOff)
                case .unauthorized:
                    return .failure(.unauthorized)
                case .unsupported:
                    return .failure(.unsupported)
                default:
                    return .failure(.unknownState)
                }
            }
            .sink { c in
                
            } receiveValue: { v in
                self.bluetoothStates.send(v)
            }
            .store(in: &cancelables)
        
        scanner.devicePublisher
            .sink { device in
                if !self.scanResults.contains(device) {
                    self.scanResults.appendDistinct(device)
                }
            }
            .store(in: &cancelables)
        
        registeredDeviceManager.refreshDevices(appData: appData)
            .sink { completion in
                // TODO: handle completion
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
