//
//  TabBarLayoutView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 11/3/21.
//

import SwiftUI

struct TabBarLayoutView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: View
    
    var body: some View {
        TabView {
            ForEach(Tabs.availableCases) { tab in
                tab.view
                    .setTitle(tab.description)
                    .toolbar {
                        ProjectSelectionView()
                            .toolbarItem()
                    }
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
                .environmentObject(Preview.projectsPreviewAppData)
                .environmentObject(Preview.mockScannerData)
        }
        Group {
            TabBarLayoutView()
                .preferredColorScheme(.dark)
                .environmentObject(Preview.projectsPreviewAppData)
                .environmentObject(Preview.mockScannerData)
        }
    }
}
#endif
