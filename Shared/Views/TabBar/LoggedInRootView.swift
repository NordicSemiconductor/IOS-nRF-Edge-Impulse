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
        return UIDevice.current.orientation == .portrait
            || horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
    
    @State var selectedTab: Tabs? = .Projects
    
    var body: some View {
        if isUsingCompactLayout {
            CompactLoggedInView()
        } else {
            HStack {
                NavigationView {
                    List {
                        ForEach(Tabs.allCases) { tab in
                            HorizontalTabView(tab: tab, selectedTab: $selectedTab)
                                .withoutListRowInsets()
                        }
                    }
                    .padding(.top, 8)
                    .listStyle(SidebarListStyle())
                }
                .setBackgroundColor(.blue)
                .setSingleColumnNavigationViewStyle()
                .frame(width: 185, alignment: .leading)
                
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
            .environmentObject(ProjectList_Previews.projectsPreviewAppData)
        #elseif os(iOS)
        Group {
            LoggedInRootView()
                .previewDevice("iPhone 11")
                .preferredColorScheme(.light)
                .environmentObject(ProjectList_Previews.projectsPreviewAppData)
        }
        Group {
            Landscape {
                LoggedInRootView()
                    .preferredColorScheme(.light)
                    .environmentObject(ProjectList_Previews.projectsPreviewAppData)
            }
        }
        Group {
            LoggedInRootView()
                .previewDevice("iPad Pro (12.9-inch) (4th generation)")
                .preferredColorScheme(.dark)
                .environmentObject(ProjectList_Previews.projectsPreviewAppData)
        }
        #endif
    }
}
#endif
