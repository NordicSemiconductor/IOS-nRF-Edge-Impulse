//
//  LoggedInRootView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

struct LoggedInRootView: View {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    var isUsingCompactLayout: Bool {
        #if os(iOS)
        return horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
    
    @State var selectedTab: Tabs? = nil
    
    var body: some View {
        HStack {
            if isUsingCompactLayout {
                CompactLoggedInView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Tabs.allCases) { tab in
                        Button(action: {
                            selectedTab = tab
                        }, label: {
                            Label(tab.description, systemImage: tab.systemImageName)
                        })
                    }
                }
                .frame(maxWidth: 200, maxHeight: .infinity)
                .listStyle(SidebarListStyle())
                
                if let selectedTab = selectedTab {
                    selectedTab.view
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("A")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .accentColor(Assets.blue.color)
    }
}

// MARK: - Preview

#if DEBUG
struct LoggedInRootView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(OSX)
        LoggedInRootView()
            .environmentObject(ProjectList_Previews.previewAppData)
            .environmentObject(Scanner())
        #elseif os(iOS)
        Group {
            LoggedInRootView()
                .previewDevice("iPhone 12 mini")
                .preferredColorScheme(.light)
                .environmentObject(ProjectList_Previews.previewAppData)
        }
        Group {
            LoggedInRootView()
                .previewDevice("iPad Pro (12.9-inch) (4th generation)")
                .preferredColorScheme(.dark)
                .environmentObject(ProjectList_Previews.previewAppData)
        }
        #endif
    }
}
#endif
