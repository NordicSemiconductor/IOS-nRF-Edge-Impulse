//
//  SettingsSyncView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 21/4/21.
//

import SwiftUI

struct SettingsSyncView: View {
    
    @EnvironmentObject var resourceData: ResourceData
    
    // MARK: View
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8, pinnedViews: []) {
                Text("Last SHA:")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text(resourceData.lastSavedSHA ?? "Not Available")
                
                Text("Last Update:")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text(resourceData.lastUpdateDateString ?? "Not Available")
            }
            
            Divider()
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8, pinnedViews: []) {
                Text("Status:")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("Up To Date")
            }
            
            Button("Trigger Update") {
                
            }.padding(.top, 8)
        }
        .lineLimit(1)
        .frame(width: 300)
    }
    
    // MARK: Column Setup
    
    private var columns: [GridItem] = [
        GridItem(.fixed(100), spacing: 16),
        GridItem(.flexible(minimum: 100, maximum: .infinity), spacing: 16)
    ]
}

// MARK: - Preview

#if DEBUG
struct SettingsSyncView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSyncView()
            .environmentObject(ResourceData())
    }
}
#endif
