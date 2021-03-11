//
//  CompactLoggedInView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 11/3/21.
//

import SwiftUI

struct CompactLoggedInView: View {
    
    var body: some View {
        TabView {
            ForEach(Tabs.allCases) { tab in
                tab.view
                    .tabItem {
                        Label(tab.description, systemImage: tab.systemImageName)
                    }
                    .tag(tab.rawValue)
            }
        }
        .accentColor(Assets.blue.color)
    }
}

// MARK: - Preview

#if DEBUG
struct CompactLoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CompactLoggedInView()
                .preferredColorScheme(.light)
                .environmentObject(ProjectList_Previews.previewAppData)
        }
        Group {
            CompactLoggedInView()
                .preferredColorScheme(.dark)
                .environmentObject(ProjectList_Previews.previewAppData)
        }
    }
}
#endif
