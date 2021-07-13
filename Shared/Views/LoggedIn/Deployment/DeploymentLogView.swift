//
//  DeploymentLogView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import SwiftUI

struct DeploymentLogView: View {
    
    @EnvironmentObject var viewState: DeploymentViewState
    
    var body: some View {
        Form {
            ForEach(viewState.logMessages, id: \.self) { message in
                Text(message)
            }
        }
        .introspectTableView { tableView in
            viewState.$logMessages
                .throttle(for: .seconds(2), scheduler: RunLoop.main, latest: true)
                .sink { [weak tableView] _ in
                    tableView?.scrollToBottom()
                }
                .store(in: &viewState.cancellables)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentLogView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeploymentLogView()
                .environmentObject(DeploymentViewState())
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
