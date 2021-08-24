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
        guard category != .transport else { return }
        DispatchQueue.main.async { [unowned self] in
            self.logs.append(LogMessage(msg))
        }
    }
}

// MARK: - FirmwareUpgradeDelegate

extension DeploymentViewState: FirmwareUpgradeDelegate {
    
    func upgradeDidStart(controller: FirmwareUpgradeController) {
        DispatchQueue.main.async { [unowned self] in
            self.progress = 0.0
        }
    }
    
    func upgradeStateDidChange(from previousState: FirmwareUpgradeState, to newState: FirmwareUpgradeState) {
        // No-p.
    }
    
    func upgradeDidComplete() {
        DispatchQueue.main.async { [unowned self] in
            self.progress = 100.0
            self.status = .success
        }
    }
    
    func upgradeDidFail(inState state: FirmwareUpgradeState, with error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.reportError(error)
        }
    }
    
    func upgradeDidCancel(state: FirmwareUpgradeState) {
        DispatchQueue.main.async { [unowned self] in
            self.status = .error(NordicError(description: "Upgrade Cancelled."))
        }
    }
    
    func uploadProgressDidChange(bytesSent: Int, imageSize: Int, timestamp: Date) {
        let progress = Double(bytesSent) / Double(imageSize)
        DispatchQueue.main.async { [unowned self] in
            self.progress = progress
        }
    }
}
