//
//  DataAcquisitionSensorPicker.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 7/6/21.
//

import SwiftUI

struct DataAcquisitionSensorPicker: View {
    
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        ZStack {
            if let device = appData.dataAquisitionViewState.selectedDevice, device.sensors.hasItems {
                Picker(selection: $appData.dataAquisitionViewState.selectedSensor, label: EmptyView()) {
                    ForEach(device.sensors) { sensor in
                        Text(sensor.name).tag(sensor)
                    }
                }
                .setAsComboBoxStyle()
                .disabled(appData.dataAquisitionViewState.isSampling)
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
        DataAcquisitionSensorPicker()
            .environmentObject(Preview.projectsPreviewAppData)
            .previewLayout(.sizeThatFits)
    }
}
#endif
