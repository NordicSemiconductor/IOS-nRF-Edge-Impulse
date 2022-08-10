//
//  DeploymentErrorView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/11/21.
//

import SwiftUI

// MARK: - DeploymentErrorView

struct DeploymentErrorView: View {
    
    let error: Error
    
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
import iOS_Common_Libraries

struct DeploymentErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FormIniOSListInMacOS {
                DeploymentErrorView(error: NordicError.testError)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
