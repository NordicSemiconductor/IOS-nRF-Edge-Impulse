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
        GeometryReader { _ in
            if isUsingCompactLayout {
                CompactLoggedInView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                NavigationView {
                    List {
                        ForEach(Tabs.allCases) { tab in
                            NavigationLink(
                                destination: tab.view,
                                label: {
                                    Text(tab.description)
                                })
                        }
                    }
                    .listStyle(SidebarListStyle())
                    .frame(width: 185, alignment: .leading)
                    

                    Text("A")
                }
                .navigationViewStyle(DoubleColumnNavigationViewStyle())
                .padding()
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
