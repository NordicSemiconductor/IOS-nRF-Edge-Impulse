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
    
    @State private var showDataAcquisitionView = false
    
    // MARK: View
    
    static let Columns = [
        GridItem(.fixed(40)),
        GridItem(.flexible()),
        GridItem(.fixed(90)),
        GridItem(.fixed(55))
    ]
    
    var body: some View {
        VStack {
            Picker("Category", selection: $appData.selectedCategory) {
                ForEach(DataSample.Category.allCases) { dataType in
                    Text(dataType.rawValue.uppercasingFirst)
                        .tag(dataType)
                }
            }
            .setAsSegmentedControlStyle()
            #if os(macOS)
            .padding([.horizontal, .bottom])
            #else
            .padding(.horizontal)
            #endif
            
            List {
                DataSampleHeaderRow()
                
                #if os(macOS)
                Divider()
                    .foregroundColor(.primary)
                #endif
                
                ForEach(appData.samplesForCategory[appData.selectedCategory] ?? []) { sample in
                    DataSampleRow(sample)
                }
                
                DataSamplesFooterView(selectedCategory: appData.selectedCategory)
            }
            #if os(macOS)
            .background(Color.secondarySystemBackground)
            #endif
            addHiddenDataAcqisitionNavigationLink()
        }
        .padding(.vertical)
        .background(Color.formBackground)
        .toolbar {
            dataAcquisitionToolbarItem()
        }
    }
}

// MARK: - DataSampleHeaderRow

struct DataSampleHeaderRow: View {
    
    var body: some View {
        MultiColumnView(columns: DataSamplesView.Columns) {
            Text("")
            Text("Filename")
                .bold()
            Text("Label")
                .foregroundColor(Assets.middleGrey.color)
            Text("Length")
                .fontWeight(.light)
        }
        .lineLimit(1)
    }
}

// MARK: - Data Acquisition Navigation

private extension DataSamplesView {
    
    func addHiddenDataAcqisitionNavigationLink() -> some View {
        NavigationLink(destination:
                        DataAcquisitionView().environmentObject(appData.dataAquisitionViewState),
                       isActive: $showDataAcquisitionView) {
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
