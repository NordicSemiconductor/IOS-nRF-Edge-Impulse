//
//  DataAcquisitionSensorPicker.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 7/6/21.
//

import SwiftUI

struct DataAcquisitionSensorPicker: View {
    
    @ObservedObject var viewState: DataAcquisitionViewState
    
    var body: some View {
        ZStack {
            if let device = viewState.selectedDevice, device.sensors.hasItems {
                Picker(selection: $viewState.selectedSensor, label: EmptyView()) {
                    ForEach(device.sensors) { sensor in
                        Text(sensor.name)
                            .tag(sensor)
                    }
                }
                .setAsComboBoxStyle()
                .disabled($viewState.isSampling.wrappedValue)
            } else {
                Text("Unavailable")
                    .foregroundColor(Assets.middleGrey.color)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DataAcquisitionSensorPicker_Previews: PreviewProvider {
    static var previews: some View {
        DataAcquisitionSensorPicker(viewState: DataAcquisitionViewState())
            .environmentObject(Preview.projectsPreviewAppData)
            .previewLayout(.sizeThatFits)
    }
}
#endif
