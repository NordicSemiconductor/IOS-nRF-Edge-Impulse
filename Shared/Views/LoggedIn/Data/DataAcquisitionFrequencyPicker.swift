//
//  DataAcquisitionFrequencyPicker.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/6/21.
//

import SwiftUI
import iOS_Common_Libraries

struct DataAcquisitionFrequencyPicker: View {
    
    @ObservedObject var viewState: DataAcquisitionViewState
    
    var body: some View {
        ZStack {
            let sensor = viewState.selectedSensor
            if sensor != Constant.unselectedSensor, let frequencies = sensor.frequencies {
                Picker(selection: $viewState.selectedFrequency, label: EmptyView()) {
                    ForEach(frequencies, id: \.self) { frequency in
                        Text("\(frequency, specifier: "%.2f") Hz")
                            .tag(frequency)
                    }
                }
                .accentColor(.universalAccentColor)
                .pickerStyle(.menu)
            } else {
                Text("Unavailable")
                    .foregroundColor(.nordicMiddleGrey)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DataAcquisitionFrequencyPicker_Previews: PreviewProvider {
    static var previews: some View {
        DataAcquisitionFrequencyPicker(viewState: DataAcquisitionViewState())
            .previewLayout(.sizeThatFits)
    }
}
#endif
