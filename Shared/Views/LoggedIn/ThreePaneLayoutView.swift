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
                Section(header: Text("Tabs")) {
                    ForEach(Tabs.allCases) { tab in
                        NavigationLink(destination: tab.view,
                            label: {
                                Label(tab.description, systemImage: tab.systemImageName)
                            })
                    }
                }
                .accentColor(Assets.blue.color)
                .listStyle(SidebarListStyle())
                .toolbarPrincipalImage(Image("Nordic"))
                .setTitle("nRF Edge Impulse")
            }
            .frame(minWidth: 160)
            
            Text("Select Something")
            
            Text("Select Something Again")
        }.frame(
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
