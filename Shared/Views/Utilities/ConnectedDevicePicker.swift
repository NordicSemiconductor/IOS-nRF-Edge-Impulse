//
//  ConnectedDevicePicker.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 21/7/21.
//

import SwiftUI

// MARK: - ConnectedDevicePicker

struct ConnectedDevicePicker<SelectionValue: Hashable>: View {
    
    @EnvironmentObject var deviceData: DeviceData
    
    var selectionBinding: Binding<SelectionValue>
    
    init(_ selectionBinding: Binding<SelectionValue>) {
        self.selectionBinding = selectionBinding
    }
}

// MARK: - iOS

#if os(iOS)
extension ConnectedDevicePicker {
    
    @ViewBuilder
    var body: some View {
        let connectedDevices = deviceData.allConnectedAndReadyToUseDevices()
        if connectedDevices.hasItems {
            Picker("Selected", selection: selectionBinding) {
                ForEach(connectedDevices, id: \.self) { handler in
                    Text(handler.userVisibleName)
                        .foregroundColor(.primary)
                        .tag(handler.device)
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
#endif

// MARK: - macOS

#if os(OSX)
extension ConnectedDevicePicker {
    
    @ViewBuilder
    var body: some View {
        MultiColumnView {
            Text("Connected Device")
            Picker(selection: selectionBinding, label: EmptyView()) {
                let connectedDevices = deviceData.allConnectedAndReadyToUseDevices().compactMap({ $0.device })
                if connectedDevices.hasItems {
                    ForEach(connectedDevices) { device in
                        Text(device.name)
                            .tag(device)
                    }
                } else {
                    Text("--")
                        .tag(Constant.unselectedDevice)
                }
            }
        }
    }
}
#endif
