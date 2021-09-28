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
            
            if let firstRow = appData.inferencingViewState.results.first {
                Section(header: Text("Results")) {
                    InferencingResultsHeaderRow()
                    
                    ForEach(appData.inferencingViewState.results, id: \.self) { result in
                        InferencingResultRow(result: result)
                    }
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
        .background(Color.formBackground)
        #if os(iOS)
        .padding(.top)
        #endif
    }
}

// MARK: - InferencingResultsHeaderRow

struct InferencingResultsHeaderRow: View {
    
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

// MARK: - InferencingResultRow

struct InferencingResultRow: View {
    
    let result: InferencingResults
    
    var body: some View {
        MultiColumnView(columns: DataSamplesView.Columns) {
            ForEach(result.classification, id: \.self) { classification in
                Text("\(classification.value)")
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
