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

final class DeploymentViewState: ObservableObject {

    @Published var status: JobStatus = .idle
    
    @Published var selectedDevice = Constant.unselectedDevice
    @Published var selectedDeviceHandler: DeviceRemoteHandler! {
        didSet {
            defer { onStatusChanged(status) }
            guard let selectedDeviceHandler = selectedDeviceHandler else { return }
            selectedDevice = selectedDeviceHandler.device ?? Constant.unselectedDevice
        }
    }
    @Published var enableEONCompiler = true
    @Published var optimization: Classifier = .Unoptimized
    @Published var buildButtonText = "Build"
    @Published var buildButtonEnable = false
    
    @Published var progressManager = DeploymentProgressManager()
    @Published var logs = [LogMessage]()
    @Published var lastLogMessage = LogMessage("")
    
    // MARK: - Private Properties
    
    internal lazy var logger = Logger(Self.self)
    
    internal var socketManager: WebSocketManager!
    internal var cancellables = Set<AnyCancellable>()
    
    private var project: Project!
    private var apiToken: String!
}

// MARK: - Requests

extension DeploymentViewState {
    
    var error: NordicError? {
        guard case let .error(error) = status else { return nil }
        return error
    }
    
    func sendDeploymentInfoRequest(for selectedProject: Project, using apiToken: String) {
        setupNewDeployment(for: selectedProject, using: apiToken)
        
        guard let infoRequest = HTTPRequest.getDeploymentInfo(project: selectedProject, using: apiToken) else { return }
        status = .infoRequestSent
        Network.shared.perform(infoRequest, responseType: GetDeploymentInfoResponse.self)
            .sinkReceivingError(onError: { error in
                self.reportError(error)
            }, receiveValue: { response in
                if response.hasDeployment {
                    self.downloadModel(for: selectedProject, using: apiToken)
                } else {
                    self.sendBuildRequest(for: selectedProject, using: apiToken)
                }
            })
            .store(in: &cancellables)
    }
    
    func sendBuildRequest(for selectedProject: Project, using apiToken: String) {
        guard let buildRequest = HTTPRequest.buildModel(project: selectedProject, usingEONCompiler: enableEONCompiler,
                                                        classifier: optimization, using: apiToken) else { return }
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
                self.sendModelToDevice(responseData: data)
            })
            .store(in: &cancellables)
    }
    
    func sendModelToDevice(responseData: Data) {
        guard let device = selectedDeviceHandler else {
            reportError(NordicError(description: "No Device."))
            return
        }
        
        do {
            status = .unpackingModelData
            logs.append(LogMessage("Unpacking Server Response Archive..."))
            let firmware = try DFUPackage(responseData)
            
            status = .uploading(0)
            logs.append(LogMessage("Sending firmware to device..."))
            try device.bluetoothManager.sendUpgradeFirmware(firmware, logDelegate: self, firmwareDelegate: self)
            
            // Disconnect so reset disconnection doesn't cause an error.
            // McuMgr Library keeps its own connection during DFU.
            device.disconnect(reason: .dfuReset)
        } catch {
            reportError(error)
        }
    }
}

// MARK: - Logic

internal extension DeploymentViewState {
    
    private func onStatusChanged(_ status: JobStatus) {
        buildButtonEnable = false
        
        switch status {
        case .idle:
            progressManager = DeploymentProgressManager()
            buildButtonEnable = selectedDeviceHandler != nil
            buildButtonText = "Build"
        case .success:
            progressManager.success()
            selectedDevice = .Unselected
            buildButtonEnable = true
            buildButtonText = "Success!"
        case .socketConnecting:
            break
        case .socketConnected:
            break
        case .infoRequestSent:
            progressManager.inProgress(.building)
            logs.append(LogMessage("Checking Deployment Status..."))
        case .buildRequestSent:
            logs.append(LogMessage("Sending Build Request..."))
        case .buildingModel(_):
            break
        case .downloadingModel:
            progressManager.inProgress(.downloading)
        case .unpackingModelData:
            break
        case .uploading(_):
            progressManager.inProgress(.uploading)
        case .confirming:
            progressManager.inProgress(.confirming)
        case .applying:
            progressManager.inProgress(.applying)
        case .error(_):
            buildButtonEnable = true
            buildButtonText = "Retry"
        }
    }
    
    func receivedJobData(dataString: String) {
        switch status {
        case .buildingModel(let jobId):
            guard let jobResult = processJobMessages(dataString, for: jobId) else { return }
            guard jobResult.success else {
                reportError(NordicError(description: "Server returned Job was not successful."))
                return
            }
            
            // If we don't disconnect, the Server will do it for us.
            disconnect()
            status = .downloadingModel
            
            guard let infoRequest = HTTPRequest.getDeploymentInfo(project: project, using: apiToken) else { return }
            self.logs.append(LogMessage("Checking Deployment Info once again before attempting to download."))
            Network.shared.perform(infoRequest, responseType: GetDeploymentInfoResponse.self)
                .sinkReceivingError(onError: { [weak self] error in
                    self?.reportError(error)
                }, receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    if response.hasDeployment {
                        self.downloadModel(for: self.project, using: self.apiToken)
                    } else {
                        self.reportError(NordicError(description: "There is no deployment available for this project. Please check the website or contact Edge Impulse."))
                    }
                })
                .store(in: &cancellables)
        default:
            break
        }
    }
    
    func reportError(_ error: Error) {
        logs.append(LogMessage(error))
        status = .error(NordicError(description: error.localizedDescription))
        progressManager.onError(error)
        
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    private func setupNewDeployment(for project: Project, using apiToken: String) {
        self.project = project
        self.apiToken = apiToken
        
        $status
            .sinkReceivingError(receiveValue: onStatusChanged(_:))
            .store(in: &cancellables)
        
        $logs
            .compactMap({ $0.last })
            .assign(to: \.lastLogMessage, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - DeploymentViewState.Classifier

extension DeploymentViewState {
    
    enum Classifier: String, RawRepresentable, CaseIterable {
        case Quantized
        case Unoptimized
    }
}
