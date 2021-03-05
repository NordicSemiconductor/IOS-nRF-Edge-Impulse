//
//  DataAcquisitionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/3/21.
//

import SwiftUI

struct DataAcquisitionView: View {
    
    private static let Sensors = ["Accelerometer", "Microphone", "Camera"]
    
    let project: Project
    
    @State private var label = ""
    @State private var selectedSensor = 0
    
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
            }
            
            Section(header: Text("Sample Length")) {
                HStack {
                    Text("ms")
                    Spacer()
                }
            }
        }
        .navigationBarTitle("Data Acquisition")
    }
}

// MARK: - Preview

#if DEBUG
struct NewSampleView_Previews: PreviewProvider {
    static var previews: some View {
        DataAcquisitionView(project: ProjectList_Previews.previewProjects.first!)
            .previewDevice("iPhone 12 mini")
    }
}
#endif
