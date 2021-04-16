//
//  LoggedInRootView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI
import Combine

struct LoggedInRootView: View {
    
    // MARK: Properties
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    // MARK: View
    
    var body: some View {
        layout.view()
    }
}

// MARK: - Layout

extension LoggedInRootView {
    
    var layout: LoggedInLayout {
        #if os(OSX)
        return .threePane
        #else
        if horizontalSizeClass == .compact {
            return .tabs
        }
        return .dualPane
        #endif
    }
    
    enum LoggedInLayout {
        case tabs
        case dualPane
        case threePane
        
        @ViewBuilder
        func view() -> some View {
            switch self {
            case .tabs:
                TabBarLayoutView()
            case .dualPane:
                TwoPaneLayoutView()
            case .threePane:
                ThreePaneLayoutView()
            }
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
