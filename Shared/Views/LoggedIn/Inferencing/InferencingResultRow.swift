//
//  InferencingResultRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 18/11/21.
//

import SwiftUI

// MARK: - InferencingResultRow

struct InferencingResultRow: View {
    
    static let classificationValueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.roundingMode = .halfUp
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        return formatter
    }()
    
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
                Text(InferencingResultRow.classificationValueFormatter.string(from: classification.value as NSNumber) ?? "N/A")
                    .foregroundColor(classification.value > 0.6
                                     ? .green : .gray)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.light)
            }
            
            Text(InferencingResultRow.classificationValueFormatter.string(from: NSNumber(value: result.anomaly ?? 0.0)) ?? "N/A")
                .foregroundColor(result.anomaly ?? 0.0 > 0.6
                                 ? .green : .gray)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.light)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct InferencingResultRow_Previews: PreviewProvider {
    
    static var previewResults = InferencingResults(type: "hello", classification: [
            InferencingResults.Classification(label: "Red Bull", value: 0.5),
            InferencingResults.Classification(label: "Mercedes", value: 0.4),
            InferencingResults.Classification(label: "Ferrari", value: 0.3),
            InferencingResults.Classification(label: "Aston Martin", value: 0.75),
            InferencingResults.Classification(label: "Alpine", value: 0.6)
        ], anomaly: 0.5)
    
    static var previews: some View {
        Group {
            InferencingResultRow(InferencingResultRow_Previews.previewResults)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
