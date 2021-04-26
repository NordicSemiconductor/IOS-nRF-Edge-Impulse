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
    private var bluetoothManager: BluetoothManager!
    private var webSocketManager: WebSocketManager!
    private var cancelable = Set<AnyCancellable>()
    
    private var btPublisher: AnyPublisher<Data, BluetoothManager.Error>?
    private var wsPublisher: AnyPublisher<Data, WebSocketManager.Error>?
    
    init(device: Device) {
        self.device = device
        bluetoothManager = BluetoothManager(peripheralId: device.id)
        webSocketManager = WebSocketManager()
    }
    
    deinit {
        cancelable.forEach { $0.cancel() }
        cancelable.removeAll()
    }
    
    func connect() {
        wsPublisher = webSocketManager.connect()
        btPublisher = bluetoothManager.connect()
        
        guard let wsPublisher = self.wsPublisher, let btPublisher = self.btPublisher else {
            return
        }
        
        self.device.state = .connecting
        
        btPublisher
            .decode(type: ResponseRootObject.self, decoder: JSONDecoder())
            .flatMap { [unowned self] data -> AnyPublisher<Data, Swift.Error> in
                do {
                    let hello = data.hello
                    let d = try JSONEncoder().encode(hello)
                    self.webSocketManager.send(d)
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
                if case .failure(let e) = completion {
                    AppEvents.shared.error = ErrorEvent(e)
                    self?.logger.error("Error: \(e.localizedDescription)")
                } else {
                    self?.logger.info("Connecting completed")
                }
            } receiveValue: { [weak self] (state) in
                self?.device.state = state
                self?.logger.info("New state: \(state.debugDescription)")
            }
            .store(in: &cancelable)
    }
    
    func disconnect() {
        btPublisher = nil
        wsPublisher = nil
        
        bluetoothManager.disconnect()
        webSocketManager.disconnect()
        
        device.state = .notConnected
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
    static let mock = DeviceRemoteHandler(device: Device.sample)
}
#endif
