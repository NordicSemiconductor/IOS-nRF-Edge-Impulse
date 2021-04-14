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
    
    enum State: CustomDebugStringConvertible {
        case notConnected
        case connecting
        case error(Error)
        case ready
        
        var debugDescription: String {
            switch self {
            case .notConnected:
                return "notConnected"
            case .connecting:
                return "connecting"
            case .error(let e):
                return "error: \(e.localizedDescription)"
            case .ready:
                return "ready"
            }
        }
        
        var isReady: Bool {
            if case .ready = self {
                return true
            } else {
                return false 
            }
        }
        
    }
}

class DeviceRemoteHandler {
    private let logger = Logger(category: "DeviceRemoteHandler")
    
    let scanResult: ScanResult
    private var bluetoothManager: BluetoothManager!
    private var webSocketManager: WebSocketManager!
    private var cancelable = Set<AnyCancellable>()
    
    @Published private (set) var state: State = .notConnected
    
    init(scanResult: ScanResult) {
        self.scanResult = scanResult
        bluetoothManager = BluetoothManager(peripheralId: scanResult.id)
        webSocketManager = WebSocketManager()
    }
    
    deinit {
        cancelable.forEach { $0.cancel() }
    }
    
    func connect() {
        self.state = .connecting

        let wsPublisher = webSocketManager.connect()
        
        bluetoothManager.connect()
            .mapError { Error.anyError($0) }
            .decode(type: ResponseRootObject.self, decoder: JSONDecoder())
            .flatMap { [unowned self] data -> AnyPublisher<Data, Swift.Error> in
                do {
                    let hello = data.hello
                    let d = try JSONEncoder().encode(hello)
                    self.webSocketManager.send(d)
                } catch let e {
                    return Result.Publisher(.failure(e)).eraseToAnyPublisher()
                }
                return wsPublisher.mapError({ Error.anyError($0) }).eraseToAnyPublisher()
            }
            .decode(type: WSHelloResponse.self, decoder: JSONDecoder())
            .mapError { Error.anyError($0) }
            .flatMap { (response) -> AnyPublisher<State, Error> in
                if let e = response.err {
                    return Result.Publisher(.failure(.stringError(e))).eraseToAnyPublisher()
                } else {
                    return Result.Publisher(.success(.ready)).eraseToAnyPublisher()
                }
            }
            .prefix(1)
            .timeout(5, scheduler: DispatchQueue.main, customError: { Error.timeout })
            .sink { [weak self] (completion) in
                if case .failure(let e) = completion {
                    self?.state = .error(e)
                    self?.logger.error("Error: \(e.localizedDescription)")
                } else {
                    self?.logger.info("Connecting completed")
                }
            } receiveValue: { [weak self] (state) in
                self?.state = state
                self?.logger.info("New state: \(state.debugDescription)")
            }
            .store(in: &cancelable)
    }
}

extension DeviceRemoteHandler: Hashable, Identifiable {
    static func == (lhs: DeviceRemoteHandler, rhs: DeviceRemoteHandler) -> Bool {
        lhs.scanResult == rhs.scanResult
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(scanResult)
    }
    
    var id: UUID {
        scanResult.id
    }
}

#if DEBUG
extension DeviceRemoteHandler {
    static let mock = DeviceRemoteHandler(scanResult: ScanResult.sample)
}
#endif
