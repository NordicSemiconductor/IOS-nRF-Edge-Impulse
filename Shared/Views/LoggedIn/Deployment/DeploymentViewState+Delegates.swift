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
    
    func log(_ msg: String, ofCategory category: McuMgrLogCategory, atLevel level: McuMgrLogLevel) {
        guard category != .transport, msg.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil else { return }
        DispatchQueue.main.async { [weak self] in
            self?.logs.append(LogMessage(msg))
            self?.logger.log("McuMgr: \(msg)")
        }
    }
}

// MARK: - FirmwareUpgradeDelegate

extension DeploymentViewState: FirmwareUpgradeDelegate {
    
    func upgradeDidStart(controller: FirmwareUpgradeController) {
        DispatchQueue.main.async { [weak self] in
            self?.progressManager.inProgress(.uploading)
            self?.progressManager.progress = 0.0
        }
    }
    
    func upgradeStateDidChange(from previousState: FirmwareUpgradeState, to newState: FirmwareUpgradeState) {
        DispatchQueue.main.async { [weak self] in
            switch previousState {
            case .confirm:
                self?.progressManager.inProgress(.confirming)
            case .reset:
                guard let self = self else { return }
                let expectedSwapTimeInSeconds = 45
                var remainingSwapTimeInSeconds = 0
                
                self.progressManager.inProgress(.applying)
                self.progressManager.progress = 0.0
                self.logs.append(LogMessage("Time Remaining: \(expectedSwapTimeInSeconds) seconds"))
                self.resetCountdownTimer
                    .autoconnect()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { a in
                        remainingSwapTimeInSeconds += 1
                        self.progressManager.progress = Double(remainingSwapTimeInSeconds) / Double(expectedSwapTimeInSeconds) * 100
                        self.logs.append(LogMessage("Time Remaining: \(expectedSwapTimeInSeconds - remainingSwapTimeInSeconds) seconds"))
                        guard remainingSwapTimeInSeconds == expectedSwapTimeInSeconds else { return }
                        
                        self.progressManager.success = self.uploadSuccessCallbackReceived
                        if !self.uploadSuccessCallbackReceived {
                            self.upgradeDidFail(inState: .reset, with: FirmwareUpgradeError.connectionFailedAfterReset)
                        }
                        self.cleanupState()
                        self.cancellables.removeAll()
                    })
                    .store(in: &self.cancellables)
            default:
                break
            }
        }
    }
    
    func upgradeDidComplete() {
        DispatchQueue.main.async { [weak self] in
            self?.uploadSuccessCallbackReceived = true
        }
    }
    
    func upgradeDidFail(inState state: FirmwareUpgradeState, with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.reportError(error)
            self?.cleanupState()
        }
    }
    
    func upgradeDidCancel(state: FirmwareUpgradeState) {
        DispatchQueue.main.async { [weak self] in
            self?.reportError(NordicError(description: "Upgrade Cancelled."))
            self?.cleanupState()
        }
    }
    
    func uploadProgressDidChange(bytesSent: Int, imageSize: Int, timestamp: Date) {
        let progress = Double(bytesSent) / Double(imageSize) * 100.0
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.progressManager.progress = progress
            
            if self.uploadImageSize == nil || self.uploadImageSize != imageSize {
                self.uploadTimestamp = timestamp
                self.uploadImageSize = imageSize
                self.uploadInitialBytes = bytesSent
            }
            
            // Date.timeIntervalSince1970 returns seconds
            let msSinceUploadBegan = (timestamp.timeIntervalSince1970 - self.uploadTimestamp.timeIntervalSince1970) * 1000
            guard bytesSent < imageSize else {
                // bytes / ms = kB/s
                self.progressManager.speed = Double(imageSize - self.uploadInitialBytes) / msSinceUploadBegan
                return
            }
            
            let bytesSentSinceUploadBegan = bytesSent - self.uploadInitialBytes
            // bytes / ms = kB/s
            self.progressManager.speed = Double(bytesSentSinceUploadBegan) / msSinceUploadBegan
        }
    }
}
