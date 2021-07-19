//
//  DeviceRemoteHandler.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 07/04/2021.
//

import Foundation
import Combine
import os

extension DeviceRemoteHandler {
    enum Error: Swift.Error {
        case anyError(Swift.Error)
        case stringError(String)
        case timeout
        case connectionEstablishFailed
        
        var localizedDescription: String {
            switch self {
            case .anyError(let e):
                return e.localizedDescription
            case .timeout:
                return "Timeout error"
            case .stringError(let s):
                return s
            case .connectionEstablishFailed:
                return "Can not establish connection"
            }
        }
    }
    
    enum ConnectionState: CustomDebugStringConvertible {
        
        case notConnected, connecting(ScanResult), connected(ScanResult, Device), disconnected(DisconnectReason)
        
        var debugDescription: String {
            switch self {
            case .connected(_, let device):
                return "Connected to \(device.id)"
            case .connecting(let device):
                return "Connecting to \(device.name)"
            case .notConnected:
                return "Not Connected"
            case .disconnected(let reason):
                return "Disconnected. Reason: \(reason)"
            }
        }
        
    }
    
    enum DisconnectReason: CustomDebugStringConvertible {
        case error(Swift.Error), onDemand
        
        var debugDescription: String {
            switch self {
            case .error(let e):
                return e.localizedDescription
            case .onDemand:
                return "On Demand"
            }
        }
        
    }
}

class DeviceRemoteHandler {
    private static let RemoteManagementURLString = "wss://remote-mgmt.edgeimpulse.com"
    private let logger = Logger(category: "DeviceRemoteHandler")
    
    private (set) var scanResult: ScanResult
    private (set) var device: Device?
    
    @Published var state: ConnectionState = .notConnected
    
    private (set) lazy var bluetoothManager = BluetoothManager(peripheralId: self.scanResult.uuid)
    private var webSocketManager: WebSocketManager!
    private var cancellables = Set<AnyCancellable>()
    
    private let registeredDeviceManager: RegisteredDevicesManager
    private let appData: AppData
    
    init(scanResult: ScanResult, device: Device? = nil, registeredDeviceManager: RegisteredDevicesManager = RegisteredDevicesManager(), appData: AppData) {
        self.registeredDeviceManager = registeredDeviceManager
        self.scanResult = scanResult
        self.appData = appData
        self.device = device
        
        webSocketManager = WebSocketManager()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    var userVisibleName: String {
        device?.name ?? scanResult.name
    }
    
    func connect(apiKey: String) -> AnyPublisher<ConnectionState, Never> {
        bluetoothManager.connect()
            .drop(while: { $0 != .readyToUse })
            .flatMap { _ in self.bluetoothManager.receptionSubject.gatherData(ofType: ResponseRootObject.self) }
            .combineLatest(webSocketManager.connect(to: Self.RemoteManagementURLString).drop(while: { $0 != .connected }))
            .flatMap { [webSocketManager] (data, _) -> AnyPublisher<Data, Swift.Error> in
                guard var hello = data.message, let webSocketManager = webSocketManager else {
                    return Fail(error: Error.connectionEstablishFailed).eraseToAnyPublisher()
                }
                
                hello.hello?.apiKey = apiKey
                hello.hello?.deviceId = self.scanResult.id
                
                do {
                    try webSocketManager.send(hello)
                } catch let e {
                    return Fail(error: e).eraseToAnyPublisher()
                }
                
                return webSocketManager.dataSubject
                    .tryMap { result in
                        switch result {
                        case .success(let data):
                            return data
                        case .failure(let error):
                            throw error
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .decode(type: WSHelloResponse.self, decoder: JSONDecoder())
            .flatMap { [registeredDeviceManager] response -> AnyPublisher<Device, Swift.Error> in
                if let e = response.err {
                    return Fail(error: Error.stringError(e))
                        .eraseToAnyPublisher()
                } else {
                    return registeredDeviceManager.fetchDevice(deviceId: self.scanResult.id, appData: self.appData)
                }
            }
            .justDoIt { [weak self] device in
                guard let self = self else { return }
                if let d = self.device, d.deviceId == device.deviceId {
                    return
                } else {
                    self.device = device
                    self.state = .connected(self.scanResult, device)
                }
            }
            .map { registeredDevice in
                ConnectionState.connected(self.scanResult, registeredDevice)
            }
            .prefix(1)
            .timeout(10, scheduler: DispatchQueue.main, customError: { Error.timeout })
            .catch { [weak self] error -> Just<ConnectionState> in
                self?.disconnect(reason: .error(error))
                return Just(ConnectionState.disconnected(.error(error)))
            }
            .eraseToAnyPublisher()
    }
    
    private func disconnect(reason: DisconnectReason) {        
        bluetoothManager.disconnect()
        webSocketManager.disconnect()
        
        self.state = .disconnected(reason)
        let deviceName = scanResult.name
        logger.info("\(deviceName) Disconnected.")
    }
    
    func disconnect() {
        disconnect(reason: .onDemand)
    }
}

// MARK: - DeviceRemoteHandler.SamplingState

extension DeviceRemoteHandler {
    
    enum SamplingState {
        case standby
        case requestReceived, requestStarted
        case completed
        case error(_ error: Error)
    }
}

// MARK: - Hashable, Equatable

extension DeviceRemoteHandler: Hashable, Identifiable {
    static func == (lhs: DeviceRemoteHandler, rhs: DeviceRemoteHandler) -> Bool {
        lhs.scanResult == rhs.scanResult
    }
    
    static func == (lhs: DeviceRemoteHandler, rhs: ScanResult) -> Bool {
        lhs.scanResult == rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(scanResult)
    }
    
    var id: String {
        scanResult.id
    }
}

#if DEBUG
extension DeviceRemoteHandler {
    static let mock = DeviceRemoteHandler(scanResult: ScanResult.sample, registeredDeviceManager: RegisteredDevicesManager(), appData: AppData())
}
#endif
