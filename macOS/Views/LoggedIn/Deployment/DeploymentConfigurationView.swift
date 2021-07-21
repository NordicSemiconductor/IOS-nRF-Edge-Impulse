//
//  DeploymentConfigurationView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 21/7/21.
//

import SwiftUI

struct DeploymentConfigurationView: View {
    
    @EnvironmentObject var deviceData: DeviceData
    @EnvironmentObject var viewState: DeploymentViewState
    
    var body: some View {
        VStack {
            Section(header: Text("Target").bold()) {
                ConnectedDevicePicker($viewState.selectedDeviceHandler)
            }
            .onAppear(perform: selectFirstAvailableDeviceHandler)
        }
        .setTitle("Deployment")
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeploymentConfigurationView()
                .environmentObject(Preview.mockScannerData)
                .environmentObject(DeploymentViewState())
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
