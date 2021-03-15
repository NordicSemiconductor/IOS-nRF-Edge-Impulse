//
//  HorizontalTabView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/3/21.
//

import SwiftUI

struct HorizontalTabView: View {
    
    let tab: Tabs
    @Binding var selectedTab: Tabs?
    
    var body: some View {
        Button(action: {
            guard selectedTab != tab else {
                selectedTab = nil
                return
            }
            selectedTab = tab
        }, label: {
            Label(tab.description, systemImage: tab.systemImageName)
                .frame(maxWidth: .infinity, alignment: .leading)
        })
        .buttonStyle(TabBarListButtonStyle())
        .accentColor(selectedTab != tab ? Assets.blue.color : Color.white)
        .background(selectedTab == tab ? Assets.blue.color : Color.clear)
        .cornerRadius(8)
    }
}

// MARK: - Preview

#if DEBUG
struct HorizontalTabView_Previews: PreviewProvider {
    
    @State static var selectedTab: Tabs! = Tabs.allCases.randomElement()
    
    static var previews: some View {
        List {
            ForEach(Tabs.allCases) { tab in
                HorizontalTabView(tab: tab, selectedTab: $selectedTab)
            }
        }
    }
}
#endif
