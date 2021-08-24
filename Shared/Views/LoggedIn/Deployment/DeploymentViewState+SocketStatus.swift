//
//  DeploymentViewState+SocketStatus.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 6/7/21.
//

import SwiftUI

// MARK: - SocketStatus

extension DeploymentViewState {
    
    enum JobStatus {
        case idle
        case socketConnecting, socketConnected
        case buildRequestSent, buildingModel(_ id: Int)
        case downloadingModel, unpackingModelData, performingFirmwareUpdate
        case success, error(_ error: Error)
        
        var shouldShowLogs: Bool {
            switch self {
            case .buildingModel(_), .downloadingModel, .performingFirmwareUpdate, .success, .error(_):
                return true
            default:
                return false
            }
        }
        
        var color: Color {
            switch self {
            case .idle:
                return Assets.middleGrey.color
            case .socketConnecting, .buildRequestSent, .unpackingModelData:
                return Assets.sun.color
            case .socketConnected, .buildingModel(_):
                return Assets.grass.color
            case .downloadingModel, .performingFirmwareUpdate:
                return Assets.blue.color
            case .success:
                return Color.green
            case .error(_):
                return Assets.red.color
            }
        }
        
        var text: String {
            switch self {
            case .socketConnecting:
                return "Connecting to Server..."
            case .socketConnected:
                return "Online"
            case .buildRequestSent:
                return "Request sent to Server. Awaiting Response..."
            case .buildingModel(_):
                return "Building Model..."
            case .downloadingModel:
                return "Downloading Model..."
            case .unpackingModelData:
                return "Unpacking Data..."
            case .performingFirmwareUpdate:
                return "Performing DFU..."
            case .success:
                return "Success!"
            case .error(_):
                return "Failed"
            default:
                return String(describing: self).uppercasingFirst
            }
        }
    }
}
