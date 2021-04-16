//
//  ThreePaneLayoutView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI

struct ThreePaneLayoutView: View {
    
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
                .accentColor(Assets.blue.color)
                .listStyle(SidebarListStyle())
            }
            .frame(minWidth: 160)
            
            AppHeaderView(.template)
                .frame(maxWidth: 120)
            
            AppHeaderView(.template)
                .frame(maxWidth: 120)
        }.toolbar {
            ProjectSelectionView()
                .toolbarItem()
        }
        .frame(
            minWidth: 800,
            maxWidth: .infinity,
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
