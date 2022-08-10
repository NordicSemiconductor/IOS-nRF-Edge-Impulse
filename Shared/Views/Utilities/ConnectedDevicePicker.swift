//
//  ConnectedDevicePicker.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 21/7/21.
//

import SwiftUI
import iOS_Common_Libraries

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
                    Text(deviceData.name(for: handler))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .tag(handler.device)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 75, alignment: .leading)
        } else {
            Text("No Connected Devices")
                .foregroundColor(.nordicMiddleGrey)
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
