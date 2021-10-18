//
//  InferencingView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import SwiftUI

struct InferencingView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    var body: some View {
        FormIniOSListInMacOS {
            Section(header: Text("Device")) {
                ConnectedDevicePicker($appData.inferencingViewState.selectedDeviceHandler)
                    .onAppear(perform: selectFirstAvailableDeviceHandler)
            }
            
            Section(header: Text("Results")) {
                if let firstRow = appData.inferencingViewState.results.first {
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        InferencingResultsHeaderRow(firstRow)
                        ForEach(appData.inferencingViewState.results, id: \.self) { result in
                            InferencingResultRow(result)
                        }
                    }
                } else {
                    Text("No inference results available yet.")
                        .foregroundColor(Assets.middleGrey.color)
                        .font(.caption)
                }
            }
            
            Section(header: Text("")) {
                Button(appData.inferencingViewState.buttonText, action: appData.inferencingViewState.toggleInferencing)
                    .centerTextInsideForm()
                #if os(iOS)
                    .foregroundColor(.positiveActionButtonColor)
                #endif
            }
        }
        #if os(iOS)
        .padding(.top)
        #endif
        .background(Color.formBackground)
    }
}

// MARK: - InferencingResultsHeaderRow

struct InferencingResultsHeaderRow: View {
    
    let result: InferencingResults
    private let gridItems: [GridItem]
    
    init(_ result: InferencingResults) {
        self.result = result
        self.gridItems = Array(repeating: GridItem(.flexible(minimum: 40, maximum: 90)),
                               count: result.classification.count)
    }
    
    var body: some View {
        LazyVGrid(columns: gridItems) {
            ForEach(result.classification, id: \.self) { classification in
                Text("\(classification.label.uppercasingFirst)")
            }
        }
        .lineLimit(1)
    }
}

// MARK: - InferencingResultRow

struct InferencingResultRow: View {
    
    static let classificationValueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.roundingMode = .halfUp
        formatter.maximumFractionDigits = 4
        return formatter
    }()
    
    let result: InferencingResults
    private let gridItems: [GridItem]
    
    init(_ result: InferencingResults) {
        self.result = result
        self.gridItems = Array(repeating: GridItem(.fixed(65)),
                               count: result.classification.count)
    }
    
    var body: some View {
        LazyVGrid(columns: gridItems) {
            ForEach(result.classification, id: \.self) { classification in
                Text(InferencingResultRow.classificationValueFormatter.string(from: classification.value as NSNumber) ?? "N/A")
                    .foregroundColor(classification.value > 0.6
                                     ? .green : .gray)
                    .fontWeight(.light)
            }
        }
        .lineLimit(1)
    }
}

// MARK: - Preview

#if DEBUG
struct InferencingView_Previews: PreviewProvider {
    static var previews: some View {
        InferencingView()
    }
}
#endif
