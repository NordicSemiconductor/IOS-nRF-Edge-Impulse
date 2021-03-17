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
    
    var shouldUseTabBarLayout: Bool {
        #if os(iOS)
        return UIDevice.current.orientation == .portrait
            || horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
    
    @State var selectedTab: Tabs? = .Projects
    
    var body: some View {
        if shouldUseTabBarLayout {
            CompactLoggedInView()
        } else {
            TwoPaneLayout()
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
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
                .preferredColorScheme(.dark)
                .environmentObject(ProjectList_Previews.projectsPreviewAppData)
        }
        #endif
    }
}
#endif
