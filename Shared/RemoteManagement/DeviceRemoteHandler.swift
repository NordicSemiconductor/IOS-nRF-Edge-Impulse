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
    
    enum ConnectionState {
        case notConnected, connecting, connected, disconnected(DisconnectReason)
    }
    
    enum DisconnectReason {
        case error(Swift.Error), onDemand
    }
}

class DeviceRemoteHandler {
    private let logger = Logger(category: "DeviceRemoteHandler")
    
    private (set) var device: Device
    private (set) var registeredDevice: RegisteredDevice?
    
    @Published var state: ConnectionState = .notConnected
    
    private var bluetoothManager: BluetoothManager!
    private var webSocketManager: WebSocketManager!
    private var cancellables = Set<AnyCancellable>()
    
    private var btPublisher: AnyPublisher<Data, BluetoothManager.Error>?
    private var wsPublisher: AnyPublisher<Data, WebSocketManager.Error>?
    
    private let registeredDeviceManager: RegisteredDevicesManager
    private let appData: AppData
    
    init(device: Device, registeredDeviceManager: RegisteredDevicesManager, appData: AppData) {
        self.device = device
        bluetoothManager = BluetoothManager(peripheralId: device.id)
        webSocketManager = WebSocketManager()
        self.registeredDeviceManager = registeredDeviceManager
        self.appData = appData
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func connect(apiKey: String) -> AnyPublisher<ConnectionState, Never> {
        
        #warning("check memory leaks")
        return bluetoothManager.connect()
            .drop(while: { $0 != .readyToUse })
            .flatMap { _ in self.bluetoothManager.dataPublisher.gatherData(ofType: ResponseRootObject.self) }
            .combineLatest(webSocketManager.connect().drop(while: { $0 != .connected }))
            .flatMap { (data, _) -> AnyPublisher<Data, Swift.Error> in
                guard var hello = data.message else {
                    return Fail(error: Error.connectionEstablishFailed).eraseToAnyPublisher()
                }
                
                hello.hello?.apiKey = apiKey
                hello.hello?.deviceId = self.device.id.uuidString
                
                do {
                    self.webSocketManager.send(try JSONEncoder().encode(hello))
                } catch let e {
                    return Fail(error: e).eraseToAnyPublisher()
                }
                
                return self.webSocketManager.dataSubject
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
            .flatMap { response -> AnyPublisher<RegisteredDevice, Swift.Error> in
                if let e = response.err {
                    return Fail(error: Error.stringError(e))
                        .eraseToAnyPublisher()
                } else {
                    let deviceId = self.device.id.uuidString
                    return self.registeredDeviceManager.fetchDevice(deviceId: deviceId, appData: self.appData)
                }
            }
            .justDoIt { device in
                if let d = self.registeredDevice, d.deviceId == device.deviceId {
                    return
                } else {
                    self.registeredDevice = device
                    self.state = .connected
                }
            }
            .map { _ in
                ConnectionState.connected
            }
            .prefix(1)
            .timeout(10, scheduler: DispatchQueue.main, customError: { Error.timeout })
            .catch { error -> Just<ConnectionState> in
                self.state = .disconnected(.error(error))
                return Just(ConnectionState.disconnected(.error(error)))
            }
            .eraseToAnyPublisher()
    }
    
    func sendSampleRequest(_ container: SampleRequestMessageContainer) throws {
        guard let messageData = try? JSONEncoder().encode(container) else { return }
        // TODO: Send.
    }
    
    func disconnect() {
        btPublisher = nil
        wsPublisher = nil
        
        bluetoothManager.disconnect()
        webSocketManager.disconnect()
        
        self.state = .notConnected
        let deviceName = device.name
        logger.info("\(deviceName) Disconnected.")
    }
}

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
