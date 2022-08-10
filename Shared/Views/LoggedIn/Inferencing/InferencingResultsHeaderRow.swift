//
//  InferencingResultsHeaderRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 18/11/21.
//

import SwiftUI

// MARK: - InferencingResultsHeaderRow

struct InferencingResultsHeaderRow: View {
    
    let result: InferencingResults
    private let gridItems: [GridItem]
    
    init(_ result: InferencingResults) {
        self.result = result
        self.gridItems = Array(repeating: InferencingView.CellType,
                               // +1 for Anomaly
                               count: result.classification.count + 1)
    }
    
    var body: some View {
        LazyVGrid(columns: gridItems) {
            ForEach(result.classification, id: \.self) { classification in
                Text("\(classification.label.uppercasingFirst)")
            }
            
            Text("Anomaly")
        }
        .lineLimit(1)
    }
}

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

struct InferencingResultsHeaderRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            InferencingResultsHeaderRow(Preview.inferencingResults)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
