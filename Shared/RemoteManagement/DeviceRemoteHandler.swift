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
        
        case notConnected, connecting(Device), connected(Device, RegisteredDevice), disconnected(DisconnectReason)
        
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
    private let logger = Logger(category: "DeviceRemoteHandler")
    
    private (set) var device: Device
    private (set) var registeredDevice: RegisteredDevice?
    
    @Published var state: ConnectionState = .notConnected
    
    private (set) lazy var bluetoothManager = BluetoothManager(peripheralId: self.device.id)
    private var webSocketManager: WebSocketManager!
    private var cancellables = Set<AnyCancellable>()
    
    internal var btPublisher: AnyPublisher<Data, BluetoothManager.Error>?
    private var wsPublisher: AnyPublisher<Data, WebSocketManager.Error>?
    
    private let registeredDeviceManager: RegisteredDevicesManager
    private let appData: AppData
    
    init(device: Device, registeredDevice: RegisteredDevice? = nil, registeredDeviceManager: RegisteredDevicesManager = RegisteredDevicesManager(), appData: AppData) {
        self.registeredDeviceManager = registeredDeviceManager
        self.device = device
        self.appData = appData
        self.registeredDevice = registeredDevice
        
        webSocketManager = WebSocketManager()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func connect(apiKey: String) -> AnyPublisher<ConnectionState, Never> {
        bluetoothManager.connect()
            .drop(while: { $0 != .readyToUse })
            .flatMap { _ in self.bluetoothManager.receptionSubject.gatherData(ofType: ResponseRootObject.self) }
            .combineLatest(webSocketManager.connect().drop(while: { $0 != .connected }))
            .flatMap { [webSocketManager] (data, _) -> AnyPublisher<Data, Swift.Error> in
                guard var hello = data.message, let webSocketManager = webSocketManager else {
                    return Fail(error: Error.connectionEstablishFailed).eraseToAnyPublisher()
                }
                
                hello.hello?.apiKey = apiKey
                hello.hello?.deviceId = self.device.id.uuidString
                
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
            .flatMap { [registeredDeviceManager] response -> AnyPublisher<RegisteredDevice, Swift.Error> in
                if let e = response.err {
                    return Fail(error: Error.stringError(e))
                        .eraseToAnyPublisher()
                } else {
                    let deviceId = self.device.id.uuidString
                    return registeredDeviceManager.fetchDevice(deviceId: deviceId, appData: self.appData)
                }
            }
            .justDoIt { [weak self] device in
                guard let `self` = self else { return }
                if let d = self.registeredDevice, d.deviceId == device.deviceId {
                    return
                } else {
                    self.registeredDevice = device
                    self.state = .connected(self.device, device)
                }
            }
            .map { registeredDevice in
                ConnectionState.connected(self.device, registeredDevice)
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
        btPublisher = nil
        wsPublisher = nil
        
        bluetoothManager.disconnect()
        webSocketManager.disconnect()
        
        self.state = .disconnected(reason)
        let deviceName = device.name
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
        lhs.device == rhs.device
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(device)
    }
    
    var id: UUID {
        device.id
    }
}

#if DEBUG
extension DeviceRemoteHandler {
    static let mock = DeviceRemoteHandler(device: Device.sample, registeredDeviceManager: RegisteredDevicesManager(), appData: AppData())
}
#endif
