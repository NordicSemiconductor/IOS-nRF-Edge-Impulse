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
    #if os(OSX)
    @State private var showNewSample = false
    #endif
    
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
                addNavigationLinkOnMacOS()
            }
        }
        .padding(.vertical)
        .toolbar {
            newSampleToolbarItem()
        }
    }
}

// MARK: - New Sample Navigation

private extension DataSamplesView {
    
    func addNavigationLinkOnMacOS() -> some View {
        #if os(OSX)
        NavigationLink(destination: DataAcquisitionView(), isActive: $showNewSample) {
            EmptyView()
        }
        .hidden()
        .onDisappear() {
            showNewSample = false
        }
        #else
        return EmptyView()
        #endif
    }
    
    func newSampleToolbarItem() -> some View {
        #if os(OSX)
        Button(action: {
            showNewSample = true
        }) {
            Label("New Sample", systemImage: "plus")
        }
        #else
        NavigationLink(destination: DataAcquisitionView(),
            label: {
                Label("New Sample", systemImage: "plus")
            })
        #endif
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
