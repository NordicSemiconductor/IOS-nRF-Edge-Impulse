//
//  InferencingView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import SwiftUI
import iOS_Common_Libraries

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
                        
                        Divider()
                            .foregroundColor(.primary)
                        
                        ForEach(appData.inferencingViewState.results, id: \.self) { result in
                            InferencingResultRow(result)
                        }
                    }
                    #if os(macOS)
                    .background(Color.secondarySystemBackground)
                    #endif
                }
                
                InferencingFooterView()
                    .environmentObject(appData.inferencingViewState)
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

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

struct InferencingView_Previews: PreviewProvider {
    static var previews: some View {
        InferencingView()
            .environmentObject(Preview.projectsPreviewAppData)
            .environmentObject(Preview.mockScannerData)
    }
}
#endif
