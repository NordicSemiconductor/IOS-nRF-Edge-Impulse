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
    
    @StateObject var scanner = Scanner()
    
    var isUsingCompactLayout: Bool {
        #if os(iOS)
        return horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
    
    var body: some View {
        NavigationView {
            if isUsingCompactLayout {
                RegularLoggedInView()
                    .environmentObject(scanner)
            } else {
                Text("Regular")
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
                .environmentObject(Scanner())
        }
        Group {
            LoggedInRootView()
                .previewDevice("iPad Pro (12.9-inch) (4th generation)")
                .preferredColorScheme(.dark)
                .environmentObject(ProjectList_Previews.previewAppData)
                .environmentObject(Scanner())
        }
        #endif
    }
}
#endif
