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
        return UIDevice.current.orientation == .portrait || horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
    
    @State var selectedTab: Tabs? = nil
    
    var body: some View {
        if isUsingCompactLayout {
            CompactLoggedInView()
        } else {
            HStack {
                List {
                    ForEach(Tabs.allCases) { tab in
                        HorizontalTabView(tab: tab, isSelected: selectedTab == tab)
                            .onTapGesture {
                                guard selectedTab != tab else {
                                    selectedTab = nil
                                    return
                                }
                                selectedTab = tab
                            }
                    }
                }
                .frame(width: 205, alignment: .leading)
                .listStyle(SidebarListStyle())
                
                if let selectedTab = selectedTab {
                    selectedTab.view
                } else {
                    Text("Dual-Pane")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(minWidth: 400)
        }
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
                .previewDevice("iPhone 11")
                .preferredColorScheme(.light)
                .environmentObject(ProjectList_Previews.previewAppData)
        }
        Group {
            Landscape {
                LoggedInRootView()
                    .preferredColorScheme(.light)
                    .environmentObject(ProjectList_Previews.previewAppData)
            }
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
