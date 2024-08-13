//
//  ThreePaneLayoutView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI

// MARK: - ThreePaneLayoutView

struct ThreePaneLayoutView: View {
    
    // MARK: Properties
    
    @EnvironmentObject var appData: AppData
    
    // MARK: View
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List(selection: $appData.selectedTab) {
                    Section("Tabs") {
                        ForEach(Tabs.availableCases) { tab in
                            NavigationLink(destination: tab.view(with: appData)) {
                                Label(tab.description, systemImage: tab.systemImageName)
                                    .tag(tab)
                            }
                        }
                    }
                    #if os(OSX)
                    .collapsible(false)
                    #endif
                    
                    if let user = appData.user {
                        let userTab = Tabs.User
                        Section(userTab.description) {
                            NavigationLink(destination: userTab.view(with: appData)) {
                                Label(user.formattedName, systemImage: userTab.systemImageName)
                                    .tag(userTab)
                            }
                        }
                        #if os(OSX)
                        .collapsible(false)
                        #endif
                    }
                }
                .listStyle(SidebarListStyle())
                
                SmallAppIconAndVersionView()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
            .frame(minWidth: .sidebarWidth)
            
            AppHeaderView()
            
            AppHeaderView()
                .frame(minWidth: .minTabWidth)
        }.toolbar {
            ProjectSelectionView()
                .toolbarItem()
        }
        .frame(
            minWidth: .sidebarWidth + .minTabWidth * 2,
            maxWidth: .sidebarWidth + .minTabWidth * 2,
            minHeight: 720,
            maxHeight: .infinity,
            alignment: .leading
        )
//        .frame(width: 1280, height: 748) // Frame for 1280x800 screenshots.
    }
}

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

struct ThreePaneLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        ThreePaneLayoutView()
            .environmentObject(Preview.projectsPreviewAppData)
    }
}
#endif
