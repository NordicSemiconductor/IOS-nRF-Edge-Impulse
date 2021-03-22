//
//  DeploymentView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/3/21.
//

import SwiftUI

struct DeploymentView: View {
    var body: some View {
        Text("Hello, World!")
            .setTitle("Data Acquisition")
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentView_Previews: PreviewProvider {
    static var previews: some View {
        DeploymentView()
    }
}
#endif
