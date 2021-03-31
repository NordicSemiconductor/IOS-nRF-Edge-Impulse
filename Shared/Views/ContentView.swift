//
//  ContentView.swift
//  Shared
//
//  Created by Dinesh Harjani on 22/02/2021.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var resourceData: ResourceData
    
    var body: some View {
        if appData.isLoggedIn {
            LoggedInRootView()
                .onAppear() {
                    resourceData.load()
                }
        } else {
            NativeLoginView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData())
    }
}
#endif
