//
//  DeploymentViewState.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import Combine
import SwiftUI
import McuManager
import OSLog
import ZIPFoundation

final class DeploymentViewState: ObservableObject {

    @Published var status: JobStatus = .idle
    @Published var selectedDevice = Constant.unselectedDevice
    @Published var selectedDeviceHandler: DeviceRemoteHandler! {
        didSet {
            guard let selectedDeviceHandler = selectedDeviceHandler else { return }
            selectedDevice = selectedDeviceHandler.device ?? Constant.unselectedDevice
        }
    }
    @Published var progress = 0.0
    @Published var enableEONCompiler = true
    @Published var optimization: Classifier = .Unoptimized
    @Published var logs = [LogMessage]()
    private lazy var logger = Logger(Self.self)
    
    private var socketManager: WebSocketManager!
    internal var cancellables = Set<AnyCancellable>()
    
    private var project: Project!
    private var apiToken: String!
}

// MARK: - API Properties

extension DeploymentViewState {
    
    var buildButtonEnable: Bool {
        switch status {
        case .idle:
            return selectedDeviceHandler != nil && isReadyToConnect
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

// MARK: - WebSocket

extension DeploymentViewState {
    
    func connect(using socketToken: Token) {
        guard let request = HTTPRequest(scheme: .wss, host: .EdgeImpulse, path: "/socket.io/", parameters: ["token": socketToken.socketToken, "EIO": "3", "transport": "websocket"]),
              let urlString = request.url?.absoluteString else {
            reportError(NordicError(description: "Unable to make HTTPRequest."))
            return
        }
        status = .socketConnecting
        socketManager = WebSocketManager()
        let pingConfiguration = WebSocketManager.PingConfiguration(data: "2".data(using: .utf8))
        socketManager.connect(to: urlString, using: pingConfiguration)
            .receive(on: RunLoop.main)
            .sinkReceivingError(onError: { error in
                self.reportError(error)
            }) { status in
                switch status {
                case .notConnected:
                    self.reportError(NordicError(description: "Disconnected."))
                case .connecting:
                    self.status = .socketConnecting
                case .connected:
                    self.status = .socketConnected
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

// MARK: - Requests

extension DeploymentViewState {
    
    func sendBuildRequest(for selectedProject: Project, using apiToken: String) {
        guard let buildRequest = HTTPRequest.buildModel(project: selectedProject, usingEONCompiler: enableEONCompiler,
                                                        classifier: optimization, using: apiToken) else { return }
        project = selectedProject
        self.apiToken = apiToken
        status = .buildRequestSent
        Network.shared.perform(buildRequest, responseType: BuildOnDeviceModelRequestResponse.self)
            .sinkReceivingError(onError: { error in
                self.reportError(error)
            }, receiveValue: { response in
                self.status = .buildingModel(response.id)
            })
            .store(in: &cancellables)
    }
    
    func downloadModel(for selectedProject: Project, using apiToken: String) {
        guard let downloadRequest = HTTPRequest.downloadModelFor(project: selectedProject, using: apiToken) else { return }
        Network.shared.perform(downloadRequest)
            .sinkReceivingError(onError: { error in
                self.reportError(error)
            }, receiveValue: { data in
                self.logs.append(LogMessage("Received \(data.count) bytes of Data."))
                self.unpackResponse(responseData: data)
            })
            .store(in: &cancellables)
    }
    
    func unpackResponse(responseData: Data) {
        status = .unpackingModelData
        do {
            guard let tempUrlPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
            let directoryURL = URL(fileURLWithPath: tempUrlPath, isDirectory: true)
            
            self.logs.append(LogMessage("Writing Response Data to disk..."))
            let zipFileURL = URL(fileURLWithPath: tempUrlPath + "/\(abs(responseData.hashValue)).zip")
            try responseData.write(to: zipFileURL)
            defer {
                cleanup(zipFileURL)
            }
        
            self.logs.append(LogMessage("Opening up Response Archive..."))
            guard Archive(url: zipFileURL, accessMode: .read) != nil else {
                self.logs.append(LogMessage("Welp! Response Data is not a ZIP file."))
                throw NordicError(description: "Server did not return a .ZIP file.")
            }
            
            let fileManager = FileManager()
            try fileManager.unzipItem(at: zipFileURL, to: directoryURL)
            
            let contents = try fileManager.contentsOfDirectory(atPath: directoryURL.absoluteString)
            for file in contents {
                print(file)
            }
        } catch {
            reportError(error)
        }
        
//        self.sendModelToDevice(modelData: response)
    }
    
    func sendModelToDevice(modelData: Data) {
        guard let device = selectedDeviceHandler else {
            reportError(NordicError(description: "No Device."))
            return
        }
        
        logs.append(LogMessage("Sending firmware to device..."))
        do {
            try device.bluetoothManager.sendUpgradeFirmware(modelData, logDelegate: self, firmwareDelegate: self)
            status = .performingFirmwareUpdate
        } catch {
            reportError(error)
        }
    }
}

// MARK: - Logic

internal extension DeploymentViewState {
    
    func receivedJobData(dataString: String) {
        switch status {
        case .buildingModel(let jobId):
            processJobMessages(dataString, for: jobId)
        default:
            break
        }
    }
    
    func processJobMessages(_ string: String, for jobId: Int) {
        if let message = try? SocketIOJobMessage(from: string), !message.message.isEmpty {
            guard jobId == message.job.jobId else { return }
            logs.append(LogMessage(message))
            guard message.progress > .leastNonzeroMagnitude else { return }
            progress = message.progress
        } else if let jobResult = try? SocketIOJobResult(from: string), jobResult.job.jobId == jobId {
            guard jobResult.success else {
                reportError(NordicError(description: "Server returned Job was not successful."))
                return
            }
            
            // If we don't disconnect, the Server will do it for us.
            disconnect()
            status = .downloadingModel
            downloadModel(for: project, using: apiToken)
        }
    }
    
    func reportError(_ error: Error) {
        logs.append(LogMessage(error))
        status = .error(error)
        
        for cancellable in cancellables {
            cancellable.cancel()
        }
        cancellables.removeAll()
    }
    
    private func cleanup(_ url: URL) {
        do {
            let fileManager = FileManager()
            try fileManager.removeItem(at: url)
        } catch {
            logger.debug("Unable to delete file at \(url.absoluteString): \(error.localizedDescription)")
        }
    }
}

// MARK: - DeploymentViewState.Classifier

extension DeploymentViewState {
    
    enum Classifier: String, RawRepresentable, CaseIterable {
        case Quantized
        case Unoptimized
    }
}
