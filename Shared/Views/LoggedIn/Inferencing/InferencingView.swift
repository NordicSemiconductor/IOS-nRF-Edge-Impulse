//
//  InferencingView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import SwiftUI

struct InferencingView: View {
    
    static let CellType = GridItem(.fixed(80))
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - State
    
    var body: some View {
        FormIniOSListInMacOS {
            Section(header: Text("Device")) {
                ConnectedDevicePicker($appData.inferencingViewState.selectedDevice)
            }
            
            #if os(macOS)
            Divider()
                .padding(.horizontal)
            #endif
            
            Section(header: Text("Results")) {
                if let firstRow = appData.inferencingViewState.results.first {
                    ScrollView([.horizontal], showsIndicators: true) {
                        InferencingResultsHeaderRow(firstRow)
                        ForEach(appData.inferencingViewState.results, id: \.self) { result in
                            InferencingResultRow(result)
                        }
                    }
                    
                    InferencingFooterView()
                        .environmentObject(appData.inferencingViewState)
                } else {
                    Text("No inference results available yet.")
                        .foregroundColor(Assets.middleGrey.color)
                        .font(.caption)
                }
            }
            
            #if os(macOS)
            Divider()
                .padding(.horizontal)
            #endif
            
            Button(appData.inferencingViewState.buttonText, action: toggleInferencing)
                .centerTextInsideForm()
                .disabled(!appData.inferencingViewState.buttonEnable)
            #if os(iOS)
                .foregroundColor(appData.inferencingViewState.buttonEnable
                                 ? .positiveActionButtonColor : .disabledTextColor)
            #endif
        }
        .onAppear(perform: selectFirstAvailableDevice)
        #if os(iOS)
        .padding(.top)
        #endif
        .background(Color.formBackground)
        .toolbar {
            if appData.inferencingViewState.buttonEnable {
                if appData.inferencingViewState.isInferencing {
                    Button(action: toggleInferencing) {
                        Label {
                            Text("Stop")
                        } icon: {
                            Image(systemName: "stop.fill")
                        }
                    }
                } else if !appData.inferencingViewState.isInferencing {
                    Button(action: toggleInferencing) {
                        Label {
                            Text("Start")
                        } icon: {
                            Image(systemName: "play.fill")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - InferencingResultsHeaderRow

struct InferencingResultsHeaderRow: View {
    
    let result: InferencingResults
    private let gridItems: [GridItem]
    
    init(_ result: InferencingResults) {
        self.result = result
        self.gridItems = Array(repeating: InferencingView.CellType,
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

// MARK: - Preview

#if DEBUG
struct InferencingView_Previews: PreviewProvider {
    static var previews: some View {
        InferencingView()
    }
}
#endif
