//
//  LoggedInRootView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

struct LoggedInRootView: View {
    
    enum LoggedInLayout {
        case tabs
        case dualPane
        case threePane
    }
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    var layout: LoggedInLayout {
        #if os(iOS)
        if horizontalSizeClass == .compact {
            return .tabs
        }
        return .dualPane
        #else
        return .threePane
        #endif
    }
    
    var body: some View {
        switch layout {
        case .tabs:
            TabBarLayoutView()
        case .dualPane:
            TwoPaneLayoutView()
        case .threePane:
            ThreePaneLayoutView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct LoggedInRootView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(OSX)
        LoggedInRootView()
            .environmentObject(Preview.projectsPreviewAppData)
        #elseif os(iOS)
        Group {
            LoggedInRootView()
                .previewDevice("iPhone 11")
                .preferredColorScheme(.light)
                .environmentObject(Preview.projectsPreviewAppData)
        }
        Group {
            Landscape {
                LoggedInRootView()
                    .preferredColorScheme(.light)
                    .environmentObject(Preview.projectsPreviewAppData)
            }
        }
        Group {
            LoggedInRootView()
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
                .preferredColorScheme(.dark)
                .environmentObject(Preview.projectsPreviewAppData)
        }
        #endif
    }
}
#endif
