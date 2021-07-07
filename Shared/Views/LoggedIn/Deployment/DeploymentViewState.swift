//
//  DeploymentViewState.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import Combine
import SwiftUI

final class DeploymentViewState: ObservableObject {

    @Published var status: SocketStatus = .idle
    @Published var selectedDevice = Constant.unselectedDevice
    @Published var progress = 0.0
    @Published var enableEONCompiler = true
    @Published var optimization: Classifier = .Quantized
    
    private lazy var socketManager = WebSocketManager()
    private lazy var cancellables = Set<AnyCancellable>()
}

// MARK: - API Properties

extension DeploymentViewState {
    
    var buildButtonEnable: Bool {
        guard selectedDevice != Constant.unselectedDevice else { return false }
        switch status {
        case .connected:
            return true
        default:
            return false
        }
    }
    
    var isReadyToConnect: Bool {
        switch status {
        case .idle:
            return true
        default:
            return false
        }
    }
}

// MARK: - API

extension DeploymentViewState {
    
    func connect(using socketToken: Token) {
        guard let request = HTTPRequest(scheme: .wss, host: .EdgeImpulse, path: "/socket.io/", parameters: ["token": socketToken.socketToken, "transport": "websocket"]),
              let urlString = request.url?.absoluteString else {
            status = .error(NordicError.init(description: "Unable to make HTTPRequest."))
            return
        }
        status = .connecting
        socketManager.connect(to: urlString, pingTimeout: 4)
            .flatMap { (_) -> AnyPublisher<Data, Swift.Error> in
                return self.socketManager.dataSubject
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
            .sinkReceivingError(onError: { error in
                self.status = .error(error)
            }) { data in
                self.status = .connected
                guard let message = String(bytes: data, encoding: .utf8) else { return }
                print(message)
            }
            .store(in: &cancellables)
    }
    
    func disconnect() {
        socketManager.disconnect()
        for cancellable in cancellables {
            cancellable.cancel()
        }
        cancellables.removeAll()
        status = .idle
    }
    
    func build() {
        
    }
}

// MARK: - DeploymentViewState.Duration

extension DeploymentViewState {
    
    enum Classifier: String, RawRepresentable, CaseIterable {
        case Quantized
        case Unoptimized
    }
}
