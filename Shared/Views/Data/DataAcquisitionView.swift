//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    private static let Sensors = ["Accelerometer", "Microphone", "Camera"]
    private static let Frequencies = [8000, 11000, 16000, 32000, 44100, 48000]
    
    let project: Project
    
    @State private var label = ""
    @State private var selectedSensor = 0
    @State private var sampleLength = 10000
    @State private var selectedFrequency = 1
    
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
                Picker("Type", selection: $selectedSensor) {
                    ForEach(Self.Sensors.indices) { i in
                        Text(Self.Sensors[i]).tag(i)
                    }
                }
                .pickerStyle(InlinePickerStyle())
                .frame(maxHeight: 75)
            }
            
            Section(header: Text("Sample Length")) {
                Stepper(value: $sampleLength, in: 0...100000) {
                    Text("\(sampleLength, specifier: "%d") ms")
                }
            }
            
            Section(header: Text("Frequency")) {
                Picker("Value", selection: $selectedFrequency) {
                    ForEach(Self.Frequencies.indices) { i in
                        Text("\(Self.Frequencies[i]) Hz").tag(i)
                    }
                }
                .pickerStyle(InlinePickerStyle())
                .frame(maxHeight: 75)
            }
            
            Button("Start Sampling") {
                startSampling()
            }
            .accentColor(Assets.red.color)
        }
        .padding(.top, 8)
        .navigationBarTitle("Data Acquisition")
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
