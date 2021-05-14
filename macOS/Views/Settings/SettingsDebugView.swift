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
            Button("Test Error", action: appData.raiseTestError)
                .padding(.top, 4)
        }
        .lineLimit(1)
        .frame(width: 80, height: 40)
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsDebugView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDebugView()
            .environmentObject(Preview.projectsPreviewAppData)
            .previewLayout(.sizeThatFits)
    }
}
#endif
