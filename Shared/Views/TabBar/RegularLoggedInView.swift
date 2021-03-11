//
//  RegularLoggedInView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 11/3/21.
//

import SwiftUI

struct RegularLoggedInView: View {
    
    @EnvironmentObject var scanner: Scanner
    
    var body: some View {
        TabView {
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
struct RegularLoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegularLoggedInView()
                .preferredColorScheme(.light)
                .environmentObject(ProjectList_Previews.previewAppData)
                .environmentObject(Scanner())
        }
        Group {
            RegularLoggedInView()
                .preferredColorScheme(.dark)
                .environmentObject(ProjectList_Previews.previewAppData)
                .environmentObject(Scanner())
        }
    }
}
#endif
