//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    let project: Project
    
    @State private var label = ""
    @State private var selectedSensorIndex = 0
    @State private var sampleLength = 10000
    @State private var selectedFrequencyIndex = 1
    
    var sampleLengthAndFrequencyEnabled: Bool {
        Sensor.allCases[selectedSensorIndex] != .Camera
    }
    
    var startSamplingDisabled: Bool {
        label.count < 1
    }
    
    var body: some View {
        Form {
            Section(header: Text("Project")) {
                Text("\(project.name)")
                    .font(.body)
                    .foregroundColor(Assets.middleGrey.color)
            }
            
            Section(header: Text("Label")) {
                TextField("Label", text: $label)
            }

            Section(header: Text("Sensor")) {
                Picker("Type", selection: $selectedSensorIndex) {
                    ForEach(Sensor.allCases.indices) { i in
                        Text(Sensor.allCases[i].rawValue).tag(i)
                    }
                }
                .pickerStyle(InlinePickerStyle())
                .frame(maxHeight: 75)
            }
            
            if sampleLengthAndFrequencyEnabled {
                Section(header: Text("Sample Length")) {
                    Stepper(value: $sampleLength, in: 0...100000) {
                        Text("\(sampleLength, specifier: "%d") ms")
                    }
                }
            }
            
            if sampleLengthAndFrequencyEnabled {
                Section(header: Text("Frequency")) {
                    Picker("Value", selection: $selectedFrequencyIndex) {
                        ForEach(Frequency.allCases.indices) { i in
                            Text(Frequency.allCases[i].description).tag(i)
                        }
                    }
                    .pickerStyle(InlinePickerStyle())
                    .frame(maxHeight: 75)
                }
            }
            
            Button("Start Sampling") {
                startSampling()
            }
            .centerTextInsideForm()
            .disabled(startSamplingDisabled)
            .accentColor(startSamplingDisabled ? Assets.middleGrey.color : Assets.red.color)
        }
        .padding(.top, 8)
        .navigationTitle("Data Acquisition")
    }
}

private extension DataAcquisitionView {
    
    func startSampling() {
        
    }
}

// MARK: - Preview

#if DEBUG
struct NewSampleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DataAcquisitionView(project: ProjectList_Previews.previewProjects.first!)
                .previewDevice("iPhone 12 mini")
        }
    }
}
#endif
