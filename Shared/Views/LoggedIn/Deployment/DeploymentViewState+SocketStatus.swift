//
//  DeploymentViewState+SocketStatus.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 6/7/21.
//

import SwiftUI

// MARK: - SocketStatus

extension DeploymentViewState {
    
    enum SocketStatus {
        case idle
        case connecting
        case connected
        case buildingModel(_ id: Int)
        case downloadingModel, performingFirmwareUpdate
        case error(_ error: Error)
        
        var color: Color {
            switch self {
            case .idle:
                return Assets.middleGrey.color
            case .connecting:
                return Assets.sun.color
            case .connected, .buildingModel(_):
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
            DeploymentViewState.SocketStatus.idle.view
            DeploymentViewState.SocketStatus.connecting.view
            DeploymentViewState.SocketStatus.connected.view
            DeploymentViewState.SocketStatus.error(NordicError.testError).view
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
