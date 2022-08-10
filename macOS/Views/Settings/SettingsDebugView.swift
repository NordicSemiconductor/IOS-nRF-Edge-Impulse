//
//  SettingsDebugView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 14/5/21.
//

import SwiftUI

struct SettingsDebugView: View {
    
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        VStack {
            Text("Notifications")
                .font(.subheadline)
                .bold()
            
            VStack {
                #if DEBUG
                Button("Test Error", action: appData.raiseTestError)
                    .padding(.top, 4)
                #endif
            }
        }
        .lineLimit(1)
        .frame(width: 200, height: 60)
    }
}

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

struct SettingsDebugView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDebugView()
            .environmentObject(Preview.projectsPreviewAppData)
            .previewLayout(.sizeThatFits)
    }
}
#endif
