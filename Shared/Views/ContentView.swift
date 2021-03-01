//
//  ContentView.swift
//  Shared
//
//  Created by Dinesh Harjani on 22/02/2021.
//

import SwiftUI

struct ContentView: View {
    @StateObject var appData = AppData()
    
    var body: some View {
        if let token = appData.apiToken {
            Text("Token: \(token)")
                .padding()
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
    }
}
#endif
