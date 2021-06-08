//
//  DataAcquisitionViewSampleLengthPicker.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/6/21.
//

import SwiftUI

struct DataAcquisitionViewSampleLengthPicker: View {
    
    @ObservedObject var viewState: DataAcquisitionViewState
    
    var body: some View {
        ZStack {
            if viewState.selectedSensor != Constant.unselectedSensor,
               let maxSampleLength = viewState.selectedSensor.maxSampleLengthS {
                #if os(OSX)
                HStack {
                    Slider(value: $viewState.sampleLength, in: 0...Double(maxSampleLength))
                    Text("\(viewState.sampleLength, specifier: "%.0f") ms")
                }
                #else
                Stepper(value: $viewState.sampleLength, in: 0...Double(maxSampleLength), step: 10) {
                    Text("\(viewState.sampleLength, specifier: "%.0f") ms")
                }
                #endif
            } else {
                Text("Unavailable")
                    .foregroundColor(Assets.middleGrey.color)
            }
        }
        .disabled(viewState.isSampling)
    }
}

// MARK: - Preview

#if DEBUG
struct DataAcquisitionViewSampleLengthPicker_Previews: PreviewProvider {
    static var previews: some View {
        DataAcquisitionViewSampleLengthPicker(viewState: DataAcquisitionViewState())
            .previewLayout(.sizeThatFits)
    }
}
#endif
