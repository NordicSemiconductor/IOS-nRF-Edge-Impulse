//
//  ThreePaneLayoutView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI

struct ThreePaneLayoutView: View {
    
    // MARK: Properties
    
    @EnvironmentObject var appData: AppData
    
    // MARK: View
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    Section(header: Text("Tabs")) {
                        ForEach(Tabs.availableCases) { tab in
                            NavigationLink(destination: tab.view(with: appData), tag: tab, selection: $appData.selectedTab,
                                label: {
                                    Label(tab.description, systemImage: tab.systemImageName)
                                })
                        }
                    }
                    #if os(OSX)
                    .collapsible(false)
                    #endif
                    
                    if let user = appData.user {
                        let userTab = Tabs.User
                        Section(header: Text(userTab.description)) {
                            NavigationLink(destination: userTab.view(with: appData), tag: userTab, selection: $appData.selectedTab, label: {
                                Label(user.formattedName, systemImage: userTab.systemImageName)
                            })
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
struct ThreePaneLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        ThreePaneLayoutView()
            .environmentObject(Preview.projectsPreviewAppData)
    }
}
#endif
