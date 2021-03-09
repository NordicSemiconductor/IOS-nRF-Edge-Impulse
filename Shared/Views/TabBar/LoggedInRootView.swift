//
//  LoggedInRootView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

struct LoggedInRootView: View {
    
    @State var selectedTab: Tabs = .Projects
    @State var scanner = Scanner()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ProjectList()
                .tabItem {
                    Label(Tabs.Projects.description, systemImage: "list.bullet")
                }
                .tag(Tabs.Projects.rawValue)
            
            DeviceList()
                .environmentObject(scanner)
                .tabItem {
                    Label(Tabs.Scanner.description, systemImage: "wave.3.left")
                }
                .tag(Tabs.Scanner.rawValue)
        }
        .accentColor(Assets.blue.color)
    }
}

// MARK: - Preview

#if DEBUG
struct LoggedInRootView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInRootView()
            .environmentObject(AppData())
            .environmentObject(Scanner())
    }
}
#endif
