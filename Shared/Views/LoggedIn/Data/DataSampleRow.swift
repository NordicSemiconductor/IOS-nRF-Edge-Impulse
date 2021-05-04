//
//  DataSampleRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/5/21.
//

import SwiftUI

struct DataSampleRow: View {
    
    private let sample: DataSample
    
    // MARK: Init
    
    init(_ sample: DataSample) {
        self.sample = sample
    }
    
    // MARK: View
    
    var body: some View {
        LazyVGrid(columns: DataSamplesView.Columns, alignment: .leading) {
            Image(systemName: sample.category.symbolName)
            Text(sample.filename)
                .bold()
            Text(sample.label)
                .foregroundColor(Assets.middleGrey.color)
            Text(sample.totalLengthInSeconds())
                .fontWeight(.light)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DataSampleRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DataSampleRow(Preview.projectsPreviewAppData.samplesForCategory[.training]!.first!)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
