//
//  InferencingView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import SwiftUI

struct InferencingView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    var body: some View {
        FormIniOSListInMacOS {
            Section(header: Text("Device")) {
                ConnectedDevicePicker($appData.inferencingViewState.selectedDeviceHandler)
                    .onAppear(perform: selectFirstAvailableDeviceHandler)
            }
            
            Button(appData.inferencingViewState.buttonText, action: appData.inferencingViewState.toggleInferencing)
                .centerTextInsideForm()
            #if os(iOS)
                .foregroundColor(.positiveActionButtonColor)
            #endif
        }
        .background(Color.formBackground)
        #if os(iOS)
        .padding(.top)
        #endif
    }
}

// MARK: - Preview

#if DEBUG
struct InferencingView_Previews: PreviewProvider {
    static var previews: some View {
        InferencingView()
    }
}
#endif
