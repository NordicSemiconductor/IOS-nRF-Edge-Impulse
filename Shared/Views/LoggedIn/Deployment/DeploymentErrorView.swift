//
//  DeploymentErrorView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/11/21.
//

import SwiftUI

// MARK: - DeploymentErrorView

struct DeploymentErrorView: View {
    
    let error: NordicError
    
    var body: some View {
        Section(header: Text("Error Description")) {
            #if os(macOS)
            Divider()
                .padding(.horizontal)
            #endif
            
            // Align with the StageView items.
            HStack(spacing: 2) {
                Image(systemName: "info")
                    .frame(width: 20, height: 20)
                
                Text(error.localizedDescription)
            }
            .padding(.leading, 2)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FormIniOSListInMacOS {
                DeploymentErrorView(error: .testError)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
