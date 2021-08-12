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
    @State private var showDataAcquisitionView = false
    @State private var dataAcquisitionView = DataAcquisitionView()
    
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
                ForEach(DataSample.Category.allCases) { dataType in
                    Text(dataType.rawValue.uppercasingFirst)
                        .tag(dataType)
                }
            }
            .setAsSegmentedControlStyle()
            .padding(.horizontal)
            
            MultiColumnView(columns: DataSamplesView.Columns) {
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
            addHiddenDataAcqisitionNavigationLink()
        }
        .padding(.vertical)
        .toolbar {
            dataAcquisitionToolbarItem()
        }
    }
}

// MARK: - Data Acquisition Navigation

private extension DataSamplesView {
    
    func addHiddenDataAcqisitionNavigationLink() -> some View {
        NavigationLink(destination: dataAcquisitionView, isActive: $showDataAcquisitionView) {
            EmptyView()
        }
        .hidden()
    }
    
    func dataAcquisitionToolbarItem() -> some View {
        Button(action: {
            showDataAcquisitionView = true
        }) {
            Label("New Sample", systemImage: "plus")
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
