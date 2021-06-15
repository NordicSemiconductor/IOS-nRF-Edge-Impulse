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
    private var bluetoothManager: BluetoothManager!
    private var webSocketManager: WebSocketManager!
    private var cancellables = Set<AnyCancellable>()
    
    private var btPublisher: AnyPublisher<Data, BluetoothManager.Error>?
    private var wsPublisher: AnyPublisher<Data, WebSocketManager.Error>?
    
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
                    let d = try JSONEncoder().encode(message)
                    try self.webSocketManager.send(d)
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
    
    func samplingRequestPublisher() -> AnyPublisher<SamplingState, Swift.Error>? {
        guard let btPublisher = btPublisher else { return nil }
        
        let requestReceptionResponse = btPublisher
            .onlyDecode(type: SamplingRequestReceivedResponse.self)
            .first()
            .tryMap { [bluetoothManager] response -> SamplingState in
                guard response.sample else {
                    throw DeviceRemoteHandler.Error.stringError("Returned Not Successful.")
                }
                bluetoothManager?.mockFirmwareResponse(SamplingRequestStartedResponse(sampleStarted: true))
                return .requestReceived
            }
            .eraseToAnyPublisher()
        
        let samplingStartedResponse = btPublisher
            .onlyDecode(type: SamplingRequestStartedResponse.self)
            .first()
            .tryMap { [weak self] response -> SamplingState in
                guard response.sampleStarted else {
                    throw DeviceRemoteHandler.Error.stringError("Sampling failed to start.")
                }
                self?.bluetoothManager?.mockFirmwareResponse(SamplingRequestProgressResponse(sampleReading: true, progressPercentage: 0))
                return .requestStarted
            }
            .eraseToAnyPublisher()
        
        let samplingProgressResponse = btPublisher
            .onlyDecode(type: SamplingRequestProgressResponse.self)
            .tryMap { response throws -> SamplingState in
                guard response.sampleReading else {
                    throw DeviceRemoteHandler.Error.stringError("Firmware is not reading any data.")
                }
                return .inProgress(response.progressPercentage)
            }
            .eraseToAnyPublisher()
        
        return Publishers.MergeMany([
                requestReceptionResponse, samplingStartedResponse, samplingProgressResponse
            ])
            .eraseToAnyPublisher()
    }
    
    func sendSampleRequest(_ request: BLESampleRequestWrapper) throws {
        try bluetoothManager.write(request)
        #warning("test code")
        #if DEBUG
        bluetoothManager.mockFirmwareResponse(SamplingRequestReceivedResponse(sample: true))
        #endif
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
        case inProgress(_ progress: Int)
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
