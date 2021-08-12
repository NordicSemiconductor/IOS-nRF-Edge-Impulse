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
        case error(_ error: Error)
        
        var color: Color {
            switch self {
            case .idle:
                return Assets.middleGrey.color
            case .socketConnecting, .buildRequestSent, .unpackingModelData:
                return Assets.sun.color
            case .socketConnected, .buildingModel(_):
                return .green
            case .downloadingModel, .performingFirmwareUpdate:
                return Assets.blue.color
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
            case .error(_):
                return "Failed"
            default:
                return String(describing: self).uppercasingFirst
            }
        }
        
        @ViewBuilder
        var view: some View {
            HStack {
                ConnectionStatus(color: self.color)
                Text(text.uppercasingFirst)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG

struct SocketStatus_Previews: PreviewProvider {
    
    static var doNothing: () -> () = { }
    
    static var previews: some View {
        Group {
            DeploymentViewState.JobStatus.idle.view
            DeploymentViewState.JobStatus.socketConnecting.view
            DeploymentViewState.JobStatus.socketConnected.view
            DeploymentViewState.JobStatus.error(NordicError.testError).view
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
