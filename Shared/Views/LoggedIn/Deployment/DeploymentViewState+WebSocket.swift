//
//  DeploymentViewState+WebSocket.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 6/7/21.
//

import SwiftUI

// MARK: - WebSocket

extension DeploymentViewState {
    
    func connect(for project: Project, using socketToken: Token, and apiToken: String) {
        guard let request = HTTPRequest(scheme: .wss, host: .EdgeImpulse, path: "/socket.io/", parameters: ["token": socketToken.socketToken, "EIO": "3", "transport": "websocket"]),
              let urlString = request.url?.absoluteString else {
            reportError(NordicError(description: "Unable to make HTTPRequest."))
            return
        }
        
        setupNewDeployment(for: project, using: apiToken)
        progressManager.inProgress(.online)
        socketManager = WebSocketManager()
        let pingConfiguration = WebSocketManager.PingConfiguration(data: "2".data(using: .utf8))
        logs.append(LogMessage("Opening WebSocket..."))
        socketManager.connect(to: urlString, using: pingConfiguration)
            .receive(on: RunLoop.main)
            .sinkReceivingError(onError: { error in
                self.reportError(error)
            }) { status in
                switch status {
                case .notConnected:
                    self.reportError(NordicError(description: "Disconnected."))
                case .connecting:
                    self.logs.append(LogMessage("Handshaking..."))
                case .connected:
                    self.progressManager.completed(.online)
                    self.logs.append(LogMessage("Connected!"))
                    self.sendDeploymentInfoRequest(for: project, using: apiToken)
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
                self.reportError(error)
            }) { data in
                guard let dataString = String(bytes: data, encoding: .utf8) else { return }
                self.receivedJobData(dataString: dataString)
            }
            .store(in: &cancellables)
    }
    
    func disconnect() {
        guard let socketManager = socketManager else { return }
        socketManager.disconnect()
        self.socketManager = nil
    }
}

// MARK: - Job

extension DeploymentViewState {
    
    func processJobMessages(_ string: String, for jobId: Int) -> SocketIOJobResult? {
        if let jobResult = try? SocketIOJobResult(from: string), jobResult.job.jobId == jobId {
            return jobResult
        }
        
        if let message = try? SocketIOJobMessage(from: string), message.hasUserReadableText,
           jobId == message.job.jobId {
            
            logs.append(LogMessage(message))
            progressManager.progress = message.progress
        }
        return nil
    }
}

// MARK: - SocketStatus

extension DeploymentViewState {
    
    enum JobStatus: Hashable {
        case idle
        case socketConnecting, socketConnected
        case infoRequestSent, buildRequestSent, buildingModel(_ id: Int)
        case downloadingModel, unpackingModelData
        case uploading(_ id: Int), confirming, applying
        case success, error(_ error: NordicError)
        
        var shouldShowConfigurationView: Bool {
            switch self {
            case .idle, .socketConnecting, .socketConnected:
                return true
            default:
                return false
            }
        }
        
        static func == (lhs: DeploymentViewState.JobStatus, rhs: DeploymentViewState.JobStatus) -> Bool {
            switch (lhs, rhs) {
            case (.socketConnecting, .socketConnecting), (.socketConnected, .socketConnected), (.infoRequestSent, .infoRequestSent), (.buildRequestSent, .buildRequestSent), (.downloadingModel, .downloadingModel), (.unpackingModelData, .unpackingModelData), (.confirming, .confirming), (.applying, .applying), (.success, .success):
                return true
            case (.buildingModel(_), .buildingModel(_)):
                return true
            case (.uploading(_), .uploading(_)):
                return true
            case (.error(let i), .error(let j)):
                return i == j
            default:
                return false
            }
        }
    }
}
