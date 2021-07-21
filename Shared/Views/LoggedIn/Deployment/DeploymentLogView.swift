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
        ScrollViewReader { scroll in
            FormIniOSListInMacOS {
                Section(header: Text("Logs")) {
                    ForEach(viewState.logMessages, id: \.self) { message in
                        Text(message)
                    }
                }
            }
            .onReceive(
                viewState.$logMessages.compactMap { $0.last }) { newMessage in
                scroll.scrollTo(newMessage)
            }
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
