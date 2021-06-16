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
        
        var localizedDescription: String {
            switch self {
            case .anyError(let e):
                return e.localizedDescription
            case .timeout:
                return "Timeout error"
            case .stringError(let s):
                return s
            }
        }
    }
}

class DeviceRemoteHandler {
    
    private let logger = Logger(category: "DeviceRemoteHandler")
    
    @Published private (set) var device: Device
    @Published private (set) var samplingState: SamplingState
    internal var bluetoothManager: BluetoothManager!
    internal var webSocketManager: WebSocketManager!
    private var cancellables = Set<AnyCancellable>()
    
    internal var btPublisher: AnyPublisher<Data, BluetoothManager.Error>?
    private var wsPublisher: AnyPublisher<Data, WebSocketManager.Error>?
    
    // MARK: - Init / Deinit
    
    init(device: Device) {
        self.device = device
        self.samplingState = .standby
        bluetoothManager = BluetoothManager(peripheralId: device.id)
        webSocketManager = WebSocketManager()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func connect(using apiKey: String) {
        wsPublisher = webSocketManager.connect()
        btPublisher = bluetoothManager.connect()
        
        guard let wsPublisher = self.wsPublisher, let btPublisher = self.btPublisher else {
            return
        }
        
        self.device.state = .connecting
        
        btPublisher
            .gatherData(ofType: ResponseRootObject.self)
            .mapError { Error.anyError($0) }
            .flatMap { [unowned self] (data) -> AnyPublisher<Data, Swift.Error> in
                do {
                    guard var message = data.message else {
                        throw Error.stringError("Data contains no message.")
                    }
                    device.sensors = data.message?.hello?.sensors ?? []
                    message.hello?.apiKey = apiKey
                    message.hello?.deviceId = device.id.uuidString
                    try self.webSocketManager.send(message)
                } catch let e {
                    return Fail(error: e)
                        .eraseToAnyPublisher()
                }
                return wsPublisher
                    .mapError { Error.anyError($0) }
                    .eraseToAnyPublisher()
            }
            .decode(type: WSHelloResponse.self, decoder: JSONDecoder())
            .mapError { Error.anyError($0) }
            .flatMap { (response) -> AnyPublisher<Device.State, Error> in
                if let e = response.err {
                    return Fail(error: Error.stringError(e))
                        .eraseToAnyPublisher()
                } else {
                    return Just(.ready)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .prefix(1)
            .timeout(5, scheduler: DispatchQueue.main, customError: { Error.timeout })
            .sink { [weak self] (completion) in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    AppEvents.shared.error = ErrorEvent(error)
                    self.logger.error("Error: \(error.localizedDescription)")
                    self.disconnect()
                } else {
                    self.logger.info("Connecting completed")
                }
            } receiveValue: { [weak self] (state) in
                self?.device.state = state
                self?.logger.info("New state: \(state.debugDescription)")
            }
            .store(in: &cancellables)
    }
    
    func disconnect() {
        btPublisher = nil
        wsPublisher = nil
        
        bluetoothManager.disconnect()
        webSocketManager.disconnect()
        
        device.state = .notConnected
        let deviceName = device.name
        logger.info("\(deviceName) Disconnected.")
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
    static let mock = DeviceRemoteHandler(device: Device.sample)
}
#endif
