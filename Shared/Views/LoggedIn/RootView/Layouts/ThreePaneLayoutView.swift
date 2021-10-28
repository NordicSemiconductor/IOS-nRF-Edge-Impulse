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
                    Section(header: Text("Menu")) {
                        ForEach(Tabs.availableCases) { tab in
                            NavigationLink(destination: tab.view, tag: tab, selection: $appData.selectedTab,
                                label: {
                                    Label(tab.description, systemImage: tab.systemImageName)
                                })
                        }
                    }
                    
                    if let user = appData.user {
                        let userTab = Tabs.User
                        Section(header: Text(userTab.description)) {
                            NavigationLink(destination: userTab.view, tag: userTab, selection: $appData.selectedTab, label: {
                                Label(user.formattedName, systemImage: userTab.systemImageName)
                            })
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(minWidth: .sidebarWidth)
                
                SmallAppIconAndVersionView()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
            
            AppHeaderView(.template)
                .frame(maxWidth: 120)
            
            AppHeaderView(.template)
                .frame(maxWidth: 120)
        }.toolbar {
            ProjectSelectionView()
                .toolbarItem()
        }
        .frame(
            minWidth: .sidebarWidth + .minTabWidth * 2,
            maxWidth: .sidebarWidth + .minTabWidth * 2,
            minHeight: 400,
            maxHeight: .infinity,
            alignment: .leading
        )
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
