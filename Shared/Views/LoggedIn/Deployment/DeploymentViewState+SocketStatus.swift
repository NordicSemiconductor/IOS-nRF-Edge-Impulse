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
        func view(onRetry retryAction: @escaping () -> ()) -> some View {
            HStack {
                ConnectionStatus(color: self.color)
                switch self {
                case .error(let e):
                    Text(e.localizedDescription)
                    Button(action: retryAction) {
                        Image(systemName: "arrow.counterclockwise")
                            .padding(6)
                    }
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

struct SocketStatus_Previews: PreviewProvider {
    
    static var doNothing: () -> () = { }
    
    static var previews: some View {
        Group {
            DeploymentViewState.SocketStatus.idle.view(onRetry: SocketStatus_Previews.doNothing)
            DeploymentViewState.SocketStatus.connecting.view(onRetry: SocketStatus_Previews.doNothing)
            DeploymentViewState.SocketStatus.connected.view(onRetry: SocketStatus_Previews.doNothing)
            DeploymentViewState.SocketStatus.error(NordicError.testError).view(onRetry: SocketStatus_Previews.doNothing)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
