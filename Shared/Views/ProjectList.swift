//
//  ProjectList.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 1/3/21.
//

import SwiftUI

struct ProjectList: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        if let token = appData.apiToken {
            NavigationView {
                Text("Logged-in with Token: \(token)")
                    .navigationTitle("Welcome")
                    .toolbar {
                        Button("Logout") {
                            appData.logout()
                        }
                    }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ProjectList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData())
    }
}
#endif
