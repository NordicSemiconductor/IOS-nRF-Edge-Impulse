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
            List {
                Section(header: Text("Menu")) {
                    ForEach(Tabs.availableCases) { tab in
                        NavigationLink(destination: tab.view,
                            label: {
                                Label(tab.description, systemImage: tab.systemImageName)
                            })
                    }
                }
                
                if let user = appData.user {
                    Section(header: Text("User")) {
                        NavigationLink(destination: UserContentView().frame(width: Tabs.minTabWidth), label: {
                            Label(user.name, systemImage: "person.fill")
                        })
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: Self.sidebarWidth)
            
            AppHeaderView(.template)
                .frame(maxWidth: 120)
            
            AppHeaderView(.template)
                .frame(maxWidth: 120)
        }.toolbar {
            ProjectSelectionView()
                .toolbarItem()
        }
        .frame(
            minWidth: Self.sidebarWidth + Tabs.minTabWidth * 2,
            maxWidth: Self.sidebarWidth + Tabs.minTabWidth * 2,
            minHeight: 400,
            maxHeight: .infinity,
            alignment: .leading
        )
    }
    
    private static let sidebarWidth: CGFloat = 160
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
