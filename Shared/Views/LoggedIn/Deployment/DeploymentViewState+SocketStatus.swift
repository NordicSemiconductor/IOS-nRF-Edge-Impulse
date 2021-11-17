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
