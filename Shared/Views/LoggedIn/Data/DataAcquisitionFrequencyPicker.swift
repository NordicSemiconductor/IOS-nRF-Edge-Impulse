//
//  DataAcquisitionFrequencyPicker.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/6/21.
//

import SwiftUI

struct DataAcquisitionFrequencyPicker: View {
    
    @ObservedObject var viewState: DataAcquisitionViewState
    
    var body: some View {
        ZStack {
            if let sensor = viewState.selectedSensor, sensor != Constant.unselectedSensor, let frequencies = sensor.frequencies {
                Picker(selection: $viewState.selectedFrequency, label: EmptyView()) {
                    ForEach(frequencies, id: \.self) { frequency in
                        Text("\(frequency, specifier: "%.2f") Hz").tag(frequency)
                    }
                }
                .setAsComboBoxStyle()
            } else {
                Text("Unavailable")
                    .foregroundColor(Assets.middleGrey.color)
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
