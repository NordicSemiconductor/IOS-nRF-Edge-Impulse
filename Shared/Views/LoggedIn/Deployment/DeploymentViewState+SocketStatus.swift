//
//  DeploymentViewState+SocketStatus.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 6/7/21.
//

import SwiftUI

// MARK: - SocketStatus

extension DeploymentViewState {
    
    enum JobStatus: Hashable {
        case idle
        case socketConnecting, socketConnected
        case buildRequestSent, buildingModel(_ id: Int)
        case downloadingModel, unpackingModelData, performingFirmwareUpdate
        case success, error(_ error: NordicError)
        
        var shouldShowProgressView: Bool {
            switch self {
            case .buildingModel(_), .downloadingModel, .performingFirmwareUpdate, .success, .error(_):
                return true
            default:
                return false
            }
        }
        
        static func == (lhs: DeploymentViewState.JobStatus, rhs: DeploymentViewState.JobStatus) -> Bool {
            switch (lhs, rhs) {
            case (.socketConnecting, .socketConnecting), (.socketConnected, .socketConnected), (.buildRequestSent, .buildRequestSent), (.downloadingModel, .downloadingModel), (.unpackingModelData, .unpackingModelData), (.performingFirmwareUpdate, .performingFirmwareUpdate), (.success, .success):
                return true
            case (.buildingModel(_), .buildingModel(_)):
                return true
            case (.error(let i), .error(let j)):
                return i == j
            default:
                return false
            }
        }
    }
}
