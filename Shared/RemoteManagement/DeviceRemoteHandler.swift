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
    private var cancellables = Set<AnyCancellable>()
    
    private var btPublisher: AnyPublisher<Data, BluetoothManager.Error>?
    private var wsPublisher: AnyPublisher<Data, WebSocketManager.Error>?
    
    init(device: Device) {
        self.device = device
        bluetoothManager = BluetoothManager(peripheralId: device.id)
        webSocketManager = WebSocketManager()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func connect() {
        wsPublisher = webSocketManager.connect()
        btPublisher = bluetoothManager.connect()
        
        guard let wsPublisher = self.wsPublisher, let btPublisher = self.btPublisher else {
            return
        }
        
        self.device.state = .connecting
        
        btPublisher
            .scan(Data(), { accum, next -> Data in
                if case .some = try? JSONDecoder().decode(ResponseRootObject.self, from: accum) {
                    return next
                } else {
                    return accum + next
                }
            })
            .compactMap { try? JSONDecoder().decode(ResponseRootObject.self, from: $0) }
            .mapError { Error.anyError($0) }
            .flatMap { [unowned self] (data) -> AnyPublisher<Data, Swift.Error> in
                do {
                    let hello = (data.message?.hello)!
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
        
//        btPublisher
//            .decode(type: SampleRequestMessageResponse.self, decoder: JSONDecoder())
//            .sinkOrRaiseAppEventError { response in
//                print(response)
//            }
//            .store(in: &cancellables)
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
        
        device.state = .notConnected
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
    static let mock = DeviceRemoteHandler(device: Device.sample)
}
#endif
