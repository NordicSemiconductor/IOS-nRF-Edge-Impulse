//
//  DataSamplesFooterView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 30/8/21.
//

import SwiftUI

// MARK: - DataSamplesFooterView

struct DataSamplesFooterView: View {
    
    // MARK: Properties
    
    @EnvironmentObject var appData: AppData
    
    let selectedCategory: DataSample.Category
    
    // MARK: View
    
    var body: some View {
        HStack {
            Spacer()
            
            Text("\(appData.samplesForCategory[selectedCategory]?.count ?? 0) \(selectedCategory.rawValue.uppercasingFirst) Samples")
                .font(.footnote)
            
            Spacer()
        }
        .padding(10)
    }
}

// MARK: - Preview

#if DEBUG
struct DataSamplesFooterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DataSamplesFooterView(selectedCategory: .testing)
                .environmentObject(Preview.projectsPreviewAppData)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
