//
//  InferencingView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import SwiftUI

struct InferencingView: View {
    
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    @StateObject internal var viewState = InferencingViewState()
    
    var body: some View {
        FormIniOSListInMacOS {
            Section(header: Text("Device")) {
                ConnectedDevicePicker($viewState.selectedDeviceHandler)
                    .onAppear(perform: selectFirstAvailableDeviceHandler)
            }
            
            Button(viewState.buttonText, action: viewState.toggleInferencing)
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
