//
//  LoggedInRootView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

struct LoggedInRootView: View {
    
    @State var selectedTab: Tabs = .Projects
    @StateObject var scanner = Scanner()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tabs.allCases) { tab in
                tab.view
                    .environmentObject(scanner)
                    .tabItem {
                        Label(tab.description, systemImage: tab.systemImageName)
                    }
                    .tag(tab.rawValue)
            }
        }
        .accentColor(Assets.blue.color)
    }
}

// MARK: - Preview

#if DEBUG
struct LoggedInRootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoggedInRootView()
                .preferredColorScheme(.light)
                .environmentObject(ProjectList_Previews.previewAppData)
                .environmentObject(Scanner())
        }
        Group {
            LoggedInRootView()
                .preferredColorScheme(.dark)
                .environmentObject(ProjectList_Previews.previewAppData)
                .environmentObject(Scanner())
        }
    }
}
#endif
