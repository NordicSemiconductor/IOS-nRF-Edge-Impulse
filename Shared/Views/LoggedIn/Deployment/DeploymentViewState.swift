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
    @Published var jobMessages = [SocketIOJobMessage]()
    
    private lazy var socketManager = WebSocketManager()
    internal var cancellables = Set<AnyCancellable>()
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
        guard let request = HTTPRequest(scheme: .wss, host: .EdgeImpulse, path: "/socket.io/", parameters: ["token": socketToken.socketToken, "EIO": "3", "transport": "websocket"]),
              let urlString = request.url?.absoluteString else {
            status = .error(NordicError.init(description: "Unable to make HTTPRequest."))
            return
        }
        status = .connecting
        socketManager.connect(to: urlString, pingTimeout: 4)
            .receive(on: RunLoop.main)
            .sinkReceivingError(onError: { error in
                self.status = .error(error)
            }) { status in
                switch status {
                case .notConnected:
                    self.status = .error(NordicError(description: "Disconnected."))
                case .connecting:
                    self.status = .connecting
                case .connected:
                    self.status = .connected
                }
            }
            .store(in: &cancellables)
        
        socketManager.dataSubject
            .tryMap { result -> Data in
                switch result {
                case .success(let data):
                    return data
                case .failure(let error):
                    throw error
                }
            }
            .receive(on: RunLoop.main)
            .sinkReceivingError(onError: { error in
                self.status = .error(error)
            }) { data in
                guard let dataString = String(bytes: data, encoding: .utf8),
                      let message = try? SocketIOJobMessage(from: dataString),
                      !message.message.isEmpty else { return }
                
                switch self.status {
                case .buildingModel(let modelId):
                    guard modelId == message.jobId else { return }
                    self.jobMessages.append(message)
                    guard message.progress > .leastNonzeroMagnitude else { return }
                    self.progress = message.progress
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func sendBuildRequest(for selectedProject: Project, using apiToken: String,
                          deliveryBlock: @escaping (BuildOnDeviceModelRequestResponse?, Error?) -> Void) {
        guard let buildRequest = HTTPRequest.buildModel(project: selectedProject, using: apiToken) else { return }
        Network.shared.perform(buildRequest, responseType: BuildOnDeviceModelRequestResponse.self)
            .sinkReceivingError(onError: { error in
                deliveryBlock(nil, error)
            }, receiveValue: { response in
                deliveryBlock(response, nil)
            })
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
}

// MARK: - DeploymentViewState.Duration

extension DeploymentViewState {
    
    enum Classifier: String, RawRepresentable, CaseIterable {
        case Quantized
        case Unoptimized
    }
}
