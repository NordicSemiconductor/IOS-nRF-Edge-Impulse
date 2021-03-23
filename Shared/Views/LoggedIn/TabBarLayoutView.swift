//
//  TabBarLayoutView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 11/3/21.
//

import SwiftUI

struct TabBarLayoutView: View {
    
    var body: some View {
        TabView {
            ForEach(Tabs.allCases) { tab in
                tab.view
                    .setTitle(tab.description)
                    .wrapInNavigationViewForiOS()
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
struct TabBarLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabBarLayoutView()
                .preferredColorScheme(.light)
                .environmentObject(ProjectList_Previews.projectsPreviewAppData)
        }
        Group {
            TabBarLayoutView()
                .preferredColorScheme(.dark)
                .environmentObject(ProjectList_Previews.projectsPreviewAppData)
        }
    }
}
#endif
