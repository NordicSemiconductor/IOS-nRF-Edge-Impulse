//
//  DeploymentViewState.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import Combine
import SwiftUI
import iOSMcuManagerLibrary
import OSLog
import iOS_Common_Libraries

// MARK: - DeploymentViewState

final class DeploymentViewState: ObservableObject {

    @Published var selectedDevice: Device = .Unselected
    @Published var selectedDeviceHandler: DeviceRemoteHandler! {
        didSet {
            guard let selectedDeviceHandler else {
                buildButtonEnable = false
                return
            }
            selectedDevice = selectedDeviceHandler.device ?? .Unselected
            guard !pipelineManager.inProgress else { return }
            buildButtonEnable = selectedDevice != .Unselected
        }
    }
    @Published var enableEONCompiler = true
    @Published var optimization: Classifier = .Default
    @Published var enableCachedServerBuilds = true
    @Published var buildButtonText = "Build"
    @Published var buildButtonEnable = false
    
    @Published var pipelineManager = PipelineManager(initialStages: DeploymentStage.allCases)
    @Published var logs = [LogMessage]()
    @Published var lastLogMessage = LogMessage("")
    
    @Published var speed: Double?
    var speedString: String? {
        guard let speed else { return nil }
        return String(format: "Speed: %.2f kB/s", speed)
    }
    
    // MARK: Private Properties
    
    internal lazy var logger = Logger(Self.self)
    
    internal var socketManager: WebSocketManager!
    internal var cancellables = Set<AnyCancellable>()
    internal var uploadInitialBytes: Int = 0
    internal var uploadImageSize: Int!
    internal var uploadTimestamp: Date!
    internal var resetCountdownTimer = Timer.publish(every: 1, on: .main, in: .common)
    internal var uploadSuccessCallbackReceived = false
    
    private var project: Project!
    private var projectApiToken: String!
    private var buildJobId: Int!
}

// MARK: - Requests

extension DeploymentViewState {
    
    func sendDeploymentInfoRequest(for selectedProject: Project, using projectApiToken: String) {
        guard let infoRequest = HTTPRequest.getDeploymentInfo(project: selectedProject, using: projectApiToken) else { return }
        pipelineManager.inProgress(.building)
        Network.shared.perform(infoRequest, responseType: GetDeploymentInfoResponse.self)
            .sinkReceivingError(onError: { error in
                self.reportError(error)
            }, receiveValue: { response in
                if response.hasDeployment {
                    self.downloadModel(for: selectedProject, using: projectApiToken)
                } else {
                    self.sendBuildRequest(for: selectedProject, using: projectApiToken)
                }
            })
            .store(in: &cancellables)
    }
    
    func sendBuildRequest(for selectedProject: Project, using projectApiToken: String) {
        guard let buildRequest = HTTPRequest.buildModel(project: selectedProject, usingEONCompiler: enableEONCompiler,
                                                        classifier: optimization, using: projectApiToken) else { return }
        pipelineManager.inProgress(.building)
        Network.shared.perform(buildRequest, responseType: BuildOnDeviceModelRequestResponse.self)
            .sinkReceivingError(onError: { error in
                self.reportError(error)
            }, receiveValue: { response in
                self.buildJobId = response.id
            })
            .store(in: &cancellables)
    }
    
    func downloadModel(for selectedProject: Project, using projectApiToken: String) {
        guard let downloadRequest = HTTPRequest.downloadModelFor(project: selectedProject, using: projectApiToken) else { return }
        pipelineManager.inProgress(.downloading)
        Network.shared.perform(downloadRequest)
            .sinkReceivingError(onError: { error in
                self.reportError(error)
            }, receiveValue: { data in
                self.logs.append(LogMessage("Received \(data.count) bytes of Data."))
                self.pipelineManager.completed(.downloading)
                self.sendModelToDevice(responseData: data)
            })
            .store(in: &cancellables)
    }
    
    func sendModelToDevice(responseData: Data) {
        guard let selectedDeviceHandler else {
            reportError(NordicError(description: "No Device."))
            return
        }
        
        do {
            logs.append(LogMessage("Unpacking Server Response Archive..."))
            let firmware = try DFUPackage(responseData)
            
            pipelineManager.inProgress(.uploading)
            logs.append(LogMessage("Sending firmware to device..."))
            try selectedDeviceHandler.bluetoothManager.sendUpgradeFirmware(firmware, logDelegate: self, firmwareDelegate: self)
            
            // Disconnect so reset disconnection doesn't cause an error.
            // McuMgr Library keeps its own connection during DFU.
            selectedDeviceHandler.disconnect(reason: .dfuReset)
        } catch {
            reportError(error)
        }
    }
}

// MARK: - Logic

internal extension DeploymentViewState {
    
    func receivedJobData(dataString: String) {
        guard let buildJobId else { return }
        
        guard let jobResult = processJobMessages(dataString, for: buildJobId) else { return }
        guard jobResult.success else {
            reportError(NordicError(description: "Server returned Job was not successful."))
            return
        }
        
        // If we don't disconnect, the Server will do it for us.
        disconnect()
        
        guard let infoRequest = HTTPRequest.getDeploymentInfo(project: project, using: projectApiToken) else { return }
        self.logs.append(LogMessage("Checking Deployment Info once again before attempting to download."))
        Network.shared.perform(infoRequest, responseType: GetDeploymentInfoResponse.self)
            .sinkReceivingError(onError: { [weak self] error in
                self?.reportError(error)
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                if response.hasDeployment {
                    self.downloadModel(for: self.project, using: self.projectApiToken)
                } else {
                    self.reportError(NordicError(description: "There is no deployment available for this project. Please check the website or contact Edge Impulse."))
                }
            })
            .store(in: &cancellables)
    }
    
    func reportError(_ error: Error) {
        logs.append(LogMessage(error))
        pipelineManager.onError(error)
        buildButtonEnable = true
        buildButtonText = "Retry"
        
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func setupNewDeployment(for project: Project, using projectApiToken: String) {
        self.project = project
        self.projectApiToken = projectApiToken
        self.buildJobId = nil
        
        $logs
            .compactMap({ $0.last })
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastLogMessage, on: self)
            .store(in: &cancellables)
    }
    
    func cleanupState() {
        uploadInitialBytes = 0
        uploadImageSize = nil
        uploadTimestamp = nil
    }
}

// MARK: - DeploymentViewState.Classifier

extension DeploymentViewState {
    
    enum Classifier: String, RawRepresentable, CaseIterable {
        case Default
        case Quantized
        case Unoptimized
        
        var requestValue: String? {
            switch self {
            case .Default:
                return nil
            case .Quantized:
                return "int8"
            case .Unoptimized:
                return "float32"
            }
        }
        
        var userDescription: String {
            requestValue ?? "(Set by Server)"
        }
        
        static var userCaption = "Should you encounter any Build issues regarding this setting, we recommend getting in touch with Edge Impulse for more information."
        
        #if os(iOS)
        static var attributedUserCaption: AttributedString {
            var attributedString = AttributedString(DeploymentViewState.Classifier.userCaption)
            if let range = attributedString.range(of: "getting in touch with Edge Impulse"),
               let link = URL(string: "https://www.edgeimpulse.com/contact-us") {
                attributedString[range].link = link
                attributedString[range].foregroundColor = .nordicBlue
            }
            return attributedString
        }
        #endif
    }
}
