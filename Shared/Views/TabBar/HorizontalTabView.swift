//
//  HorizontalTabView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/3/21.
//

import SwiftUI

struct HorizontalTabView: View {
    let tab: Tabs
    let isSelected: Bool
    
    var body: some View {
        Label(tab.description, systemImage: tab.systemImageName)
            .padding(.leading, 4)
            .frame(height: 30)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Assets.blue.color : Color.clear)
            .cornerRadius(8)
    }
}

struct HorizontalTabView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(Tabs.allCases) { tab in
                HorizontalTabView(tab: tab, isSelected: Bool.random())
            }
        }
    }
}
