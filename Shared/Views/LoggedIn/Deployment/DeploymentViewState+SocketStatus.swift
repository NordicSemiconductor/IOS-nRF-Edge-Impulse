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
        case error(_ error: Error)
        
        var color: Color {
            switch self {
            case .idle:
                return Assets.middleGrey.color
            case .connecting:
                return Assets.sun.color
            case .connected:
                return .green
            case .error(_):
                return Assets.red.color
            }
        }
        
        @ViewBuilder
        var view: some View {
            HStack {
                ConnectionStatus(color: self.color)
                switch self {
                case .error(let e):
                    Text(e.localizedDescription)
                default:
                    Text((String(describing: self).uppercasingFirst))
                        .lineLimit(1)
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentViewState_SocketStatus_Previews: PreviewProvider {
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
