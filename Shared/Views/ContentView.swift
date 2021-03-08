//
//  ContentView.swift
//  Shared
//
//  Created by Dinesh Harjani on 22/02/2021.
//

import SwiftUI

struct ContentView: View {
    @StateObject var appData = AppData()
    @StateObject var scanner = Scanner()
    
    var body: some View {
        if appData.isLoggedIn {
            ProjectList()
                .environmentObject(appData)
        } else {
            NativeLoginView()
                .environmentObject(appData)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData())
            .environmentObject(Scanner())
    }
}
#endif
