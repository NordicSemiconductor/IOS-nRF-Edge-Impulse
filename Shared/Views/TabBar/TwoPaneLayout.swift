//
//  TwoPaneLayout.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 17/3/21.
//

import SwiftUI

struct TwoPaneLayout: View {
    
    @State var selectedTab: Tabs? = .Projects
    
    var body: some View {
        HStack {
            NavigationView {
                List {
                    Section(header: Text("Tabs")) {
                        ForEach(Tabs.allCases) { tab in
                            HorizontalTabView(tab: tab, selectedTab: $selectedTab)
                                .withoutListRowInsets()
                        }
                    }
                    .accentColor(Assets.blue.color)
                }
                .setTitle("nRF Edge Impulse")
                .padding(.top, 8)
                .listStyle(SidebarListStyle())
                .toolbarPrincipalImage(Image("Nordic"))
            }
            .setBackgroundColor(.blue)
            .setSingleColumnNavigationViewStyle()
            .frame(width: 215, alignment: .leading)
            
            VStack {
                if let selectedTab = selectedTab {
                    selectedTab.view
                } else {
                    Text("Select a Tab from the left Pane.")
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct TwoPaneLayout_Previews: PreviewProvider {
    static var previews: some View {
        TwoPaneLayout()
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
            .environmentObject(ProjectList_Previews.projectsPreviewAppData)
    }
}
