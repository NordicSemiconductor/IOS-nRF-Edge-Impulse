//
//  DataAcquisitionDevicePicker.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 7/6/21.
//

import SwiftUI

struct DataAcquisitionDevicePicker: View {
    
    @ObservedObject var viewState: DataAcquisitionViewState
    
    var body: some View {
        ZStack {
            if let device = viewState.selectedDevice, device.sensors.hasItems {
                Picker(selection: $viewState.selectedSensor, label: EmptyView()) {
                    ForEach(device.sensors) { sensor in
                        Text(sensor.name).tag(sensor)
                    }
                }
                .setAsComboBoxStyle()
                .disabled(viewState.isSampling)
            } else {
                Text("Unavailable")
                    .foregroundColor(Assets.middleGrey.color)
            }
        }
    }
}

struct DataAquisitionDevicePicker_Previews: PreviewProvider {
    static var previews: some View {
        DataAcquisitionDevicePicker(viewState: DataAcquisitionViewState())
            .previewLayout(.sizeThatFits)
    }
}
