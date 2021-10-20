//
//  DeploymentViewState+Delegates.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/7/21.
//

import Foundation
import McuManager

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
            self?.progress = 0.0
        }
    }
    
    func upgradeStateDidChange(from previousState: FirmwareUpgradeState, to newState: FirmwareUpgradeState) {
        switch previousState {
        case .reset:
            status = .applying
        case .confirm:
            status = .confirming
        default:
            break
        }
    }
    
    func upgradeDidComplete() {
        DispatchQueue.main.async { [weak self] in
            self?.progress = 100.0
            self?.status = .success
        }
    }
    
    func upgradeDidFail(inState state: FirmwareUpgradeState, with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.reportError(error)
        }
    }
    
    func upgradeDidCancel(state: FirmwareUpgradeState) {
        DispatchQueue.main.async { [weak self] in
            self?.status = .error(NordicError(description: "Upgrade Cancelled."))
        }
    }
    
    func uploadProgressDidChange(bytesSent: Int, imageSize: Int, timestamp: Date) {
        let progress = Double(bytesSent) / Double(imageSize) * 100.0
        DispatchQueue.main.async { [weak self] in
            self?.progress = progress
            self?.status = .uploading(Int(progress))
        }
    }
}
