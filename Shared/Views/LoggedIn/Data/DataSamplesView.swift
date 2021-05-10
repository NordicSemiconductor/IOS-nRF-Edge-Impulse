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
    
    static let Columns = [
        GridItem(.fixed(40)),
        GridItem(.flexible()),
        GridItem(.fixed(90)),
        GridItem(.fixed(55))
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            Picker("Category", selection: $selectedCategory) {
                ForEach(DataSample.Category.userVisible) { dataType in
                    Text(dataType.rawValue.uppercasingFirst)
                        .tag(dataType)
                }
            }
            .setAsSegmentedControlStyle()
            .padding(.horizontal)
            
            LazyVGrid(columns: DataSamplesView.Columns, alignment: .leading) {
                Text("")
                Text("Filename")
                    .bold()
                Text("Label")
                    .foregroundColor(Assets.middleGrey.color)
                Text("Length")
                    .fontWeight(.light)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            List {
                ForEach(appData.samplesForCategory[selectedCategory] ?? []) { sample in
                    DataSampleRow(sample)
                }
            }
        }
        .padding(.vertical)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                NavigationLink(destination: DataAcquisitionView(),
                    label: {
                        Label("New Sample", systemImage: "plus")
                    })
            }
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
