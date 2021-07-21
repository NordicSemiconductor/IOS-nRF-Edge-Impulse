//
//  ConnectedDevicePicker.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 21/7/21.
//

import SwiftUI

struct ConnectedDevicePicker<SelectionValue: Hashable>: View {
    
    @EnvironmentObject var deviceData: DeviceData
    
    var selectionBinding: Binding<SelectionValue>
    
    init(_ selectionBinding: Binding<SelectionValue>) {
        self.selectionBinding = selectionBinding
    }
    
    var body: some View {
        let connectedDevices = deviceData.allConnectedAndReadyToUseDevices()
        if connectedDevices.hasItems {
            Picker("Selected", selection: selectionBinding) {
                ForEach(connectedDevices, id: \.self) { handler in
                    Text(handler.userVisibleName).tag(handler.device)
                }
            }
            .setAsComboBoxStyle()
        } else {
            Text("No Connected Devices")
                .foregroundColor(Assets.middleGrey.color)
                .multilineTextAlignment(.leading)
        }
    }
}
