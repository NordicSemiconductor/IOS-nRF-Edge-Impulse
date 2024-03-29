//
//  HorizontalTabView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/3/21.
//

import SwiftUI
import iOS_Common_Libraries

struct HorizontalTabView: View {
    
    let tab: Tabs
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        Button(action: {
            guard appData.selectedTab != tab else {
                appData.selectedTab = nil
                return
            }
            appData.selectedTab = tab
        }, label: {
            Label(tab.description, systemImage: tab.systemImageName)
                .frame(maxWidth: .infinity, alignment: .leading)
        })
        .keyboardShortcut(tab.keyboardShortcutKey, modifiers: [.command])
        .buttonStyle(TabBarListButtonStyle())
        .accentColor(appData.selectedTab != tab ? .nordicBlue : .white)
        .background(appData.selectedTab == tab ? .nordicBlue : Color.clear)
        .cornerRadius(8)
    }
}

// MARK: - Preview

#if DEBUG
struct HorizontalTabView_Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            ForEach(Tabs.allCases) { tab in
                HorizontalTabView(tab: tab)
                    .environmentObject(Preview.projectsPreviewAppData)
            }
        }
    }
}
#endif
