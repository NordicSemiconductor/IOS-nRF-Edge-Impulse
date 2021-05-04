//
//  DataSamplesView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/5/21.
//

import SwiftUI
import Combine

struct DataSamplesView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: Properties
    
    @State private var selectedCategory: DataSample.Category = .training
    
    // MARK: View
    
    var body: some View {
        VStack {
            Section(header: Text("Category")) {
                Picker("Selected", selection: $selectedCategory) {
                    ForEach(DataSample.Category.allCases) { dataType in
                        Text(dataType.rawValue)
                            .tag(dataType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("Collected Samples")) {
                List {
                    ForEach(appData.samplesForCategory[selectedCategory] ?? []) { sample in
                        Text(sample.filename)
                    }
                }
            }
        }
        .padding(.vertical)
        .onAppear() {
            guard !Constant.isRunningInPreviewMode else { return }
            appData.requestDataSamples()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DataSamplesView_Previews: PreviewProvider {
    static var previews: some View {
        DataSamplesView()
            .environmentObject(Preview.projectsPreviewAppData)
    }
}
#endif
