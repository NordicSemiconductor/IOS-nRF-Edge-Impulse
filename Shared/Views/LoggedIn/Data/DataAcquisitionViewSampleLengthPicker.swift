//
//  DataAcquisitionViewSampleLengthPicker.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/6/21.
//

import SwiftUI
import iOS_Common_Libraries

struct DataAcquisitionViewSampleLengthPicker: View {
    
    @ObservedObject var viewState: DataAcquisitionViewState
    
    var body: some View {
        ZStack {
            if let sensor = viewState.selectedSensor,
               sensor != Constant.unselectedSensor,
               let maxSampleLength = viewState.selectedSensor.maxSampleLengthS {
                
                VStack {
                    HStack {
                        Slider(value: $viewState.sampleLengthS, in: 0...Double(maxSampleLength))
                            .enabledAccent(!viewState.isSampling)
                        Text("\(Int(viewState.sampleLengthS)) seconds")
                            .enabledForeground(!viewState.isSampling)
                    }
                    
                    #if os(iOS)
                    Divider()
                    #endif
                    
                    HStack {
                        #if os(iOS)
                        Text("Text Input")
                            .foregroundColor(.disabledTextColor)
                            .frame(height: 40)
                        Spacer()
                        #endif
                        
                        TextField("AA", text: Binding(
                            get: {
                                String(format: "%.0f", viewState.sampleLengthS)
                            },
                            set: {
                                let sensor = viewState.selectedSensor
                                guard sensor != Constant.unselectedSensor else { return }

                                let maxSampleLengthS = Double(sensor.maxSampleLengthS ?? .max)
                                viewState.sampleLengthS = min(Double($0) ?? 0, maxSampleLengthS)
                            }
                        ))
                            .enabledForeground(!viewState.isSampling)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                    }
                }
            } else {
                Text("Unavailable")
                    .foregroundColor(.nordicMiddleGrey)
            }
        }
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
