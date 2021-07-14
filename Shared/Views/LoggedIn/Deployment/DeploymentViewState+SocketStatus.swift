//
//  DeploymentViewState+SocketStatus.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 6/7/21.
//

import SwiftUI

// MARK: - SocketStatus

extension DeploymentViewState {
    
    enum BuildStatus {
        case idle
        case socketConnecting, socketConnected
        case buildRequestSent, buildingModel(_ id: Int)
        case downloadingModel, performingFirmwareUpdate
        case error(_ error: Error)
        
        var color: Color {
            switch self {
            case .idle:
                return Assets.middleGrey.color
            case .socketConnecting, .buildRequestSent:
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
            case .error(let e):
                return e.localizedDescription
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
            DeploymentViewState.BuildStatus.idle.view
            DeploymentViewState.BuildStatus.socketConnecting.view
            DeploymentViewState.BuildStatus.socketConnected.view
            DeploymentViewState.BuildStatus.error(NordicError.testError).view
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
