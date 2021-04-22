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
        VStack {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8, pinnedViews: []) {
                Text("Last Check:")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text(resourceData.lastCheckDateString ?? "Not Available")
                
                Text("Last SHA:")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text(resourceData.lastSavedSHA ?? "Not Available")
            }
            
            Divider()
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8, pinnedViews: []) {
                Text("Status:")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                resourceData.status.label()
            }
            
            Button("Trigger Update", action: resourceData.forceUpdate)
                .padding(.top, 4)
        }
        .lineLimit(1)
        .frame(width: 300)
    }
    
    // MARK: Column Setup
    
    private var columns: [GridItem] = [
        GridItem(.fixed(100), spacing: 16),
        GridItem(.flexible(minimum: 200, maximum: .infinity), spacing: 16)
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
