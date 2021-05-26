//
//  TwoPaneLayoutView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 17/3/21.
//

import SwiftUI

struct TwoPaneLayoutView: View {
    
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        HStack {
            NavigationView {
                List {
                    Section(header: Text("Menu")) {
                        ForEach(Tabs.availableCases) { tab in
                            HorizontalTabView(tab: tab)
                                .withoutListRowInsets()
                        }
                    }
                    .accentColor(Assets.blue.color)
                }
                .listStyle(SidebarListStyle())
                .toolbarPrincipalImage(Image("Nordic"))
                .setTitle("nRF Edge Impulse")
            }
            .setBackgroundColor(.blue)
            .setSingleColumnNavigationViewStyle()
            .frame(width: 215, alignment: .leading)
            
            VStack {
                if let selectedTab = appData.selectedTab {
                    selectedTab.view
                        .setTitle(selectedTab.description)
                } else {
                    AppHeaderView(.template)
                        .frame(maxWidth: 120)
                }
            }
            .toolbar {
                ProjectSelectionView()
                    .toolbarItem()
            }
            .wrapInNavigationViewForiOS()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TwoPaneLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(OSX)
        TwoPaneLayoutView()
            .environmentObject(Preview.mockScannerData)
            .environmentObject(Preview.projectsPreviewAppData)
        #elseif os(iOS)
        TwoPaneLayoutView()
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
            .environmentObject(Preview.mockScannerData)
            .environmentObject(Preview.projectsPreviewAppData)
        #endif
    }
}
#endif
