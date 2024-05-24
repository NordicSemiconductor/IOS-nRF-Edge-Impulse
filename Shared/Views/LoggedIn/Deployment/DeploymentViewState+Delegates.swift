//
//  DeploymentViewState+Delegates.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/7/21.
//

import Foundation
import iOSMcuManagerLibrary

// MARK: - McuMgrLogDelegate

extension DeploymentViewState: McuMgrLogDelegate {
    
    @MainActor
    func log(_ msg: String, ofCategory category: McuMgrLogCategory, atLevel level: McuMgrLogLevel) {
        guard category != .transport, msg.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil else { return }
        logs.append(LogMessage(msg))
        logger.log("McuMgr: \(msg)")
    }
}

// MARK: - FirmwareUpgradeDelegate

extension DeploymentViewState: FirmwareUpgradeDelegate {
    
    @MainActor
    func upgradeDidStart(controller: FirmwareUpgradeController) {
        pipelineManager.inProgress(.uploading, progress: 0.0)
    }
    
    @MainActor
    func upgradeStateDidChange(from previousState: FirmwareUpgradeState, to newState: FirmwareUpgradeState) {
        switch previousState {
        case .confirm:
            speed = nil
            pipelineManager.inProgress(.confirming)
        case .reset:
            let expectedSwapTimeInSeconds = 45
            var remainingSwapTimeInSeconds = 0
            
            pipelineManager.inProgress(.applying, progress: 0.0)
            logs.append(LogMessage("Time Remaining: \(expectedSwapTimeInSeconds) seconds"))
            resetCountdownTimer
                .autoconnect()
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] a in
                    remainingSwapTimeInSeconds += 1
                    self?.pipelineManager.inProgress(.applying, progress: Float(remainingSwapTimeInSeconds) / Float(expectedSwapTimeInSeconds) * 100)
                    self?.logs.append(LogMessage("Time Remaining: \(expectedSwapTimeInSeconds - remainingSwapTimeInSeconds) seconds"))
                    guard remainingSwapTimeInSeconds == expectedSwapTimeInSeconds else { return }
                    
                    self?.pipelineManager.success = self?.uploadSuccessCallbackReceived ?? false
                    if !(self?.uploadSuccessCallbackReceived ?? false) {
                        self?.upgradeDidFail(inState: .reset, with: FirmwareUpgradeError.connectionFailedAfterReset)
                    } else {
                        self?.buildButtonEnable = true
                        self?.buildButtonText = "Success!"
                    }
                    self?.cleanupState()
                    self?.cancellables.removeAll()
                })
                .store(in: &cancellables)
        default:
            break
        }
    }
    
    @MainActor
    func upgradeDidComplete() {
        uploadSuccessCallbackReceived = true
    }
    
    @MainActor
    func upgradeDidFail(inState state: FirmwareUpgradeState, with error: Error) {
        reportError(error)
        cleanupState()
    }
    
    func upgradeDidCancel(state: FirmwareUpgradeState) {
        reportError(NordicError(description: "Upgrade Cancelled."))
        cleanupState()
    }
    
    @MainActor
    func uploadProgressDidChange(bytesSent: Int, imageSize: Int, timestamp: Date) {
        let progress = Float(bytesSent) / Float(imageSize) * 100.0
        pipelineManager.inProgress(.uploading, progress: progress)
        
        if uploadImageSize == nil || uploadImageSize != imageSize {
            uploadTimestamp = timestamp
            uploadImageSize = imageSize
            uploadInitialBytes = bytesSent
        }
        
        // Date.timeIntervalSince1970 returns seconds
        let msSinceUploadBegan = (timestamp.timeIntervalSince1970 - self.uploadTimestamp.timeIntervalSince1970) * 1000
        guard bytesSent < imageSize else {
            // bytes / ms = kB/s
            speed = Double(imageSize - uploadInitialBytes) / msSinceUploadBegan
            return
        }
        
        let bytesSentSinceUploadBegan = bytesSent - uploadInitialBytes
        // bytes / ms = kB/s
        speed = Double(bytesSentSinceUploadBegan) / msSinceUploadBegan
    }
}
