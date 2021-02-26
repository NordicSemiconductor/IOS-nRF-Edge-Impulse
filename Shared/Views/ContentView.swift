//
//  ContentView.swift
//  Shared
//
//  Created by Dinesh Harjani on 22/02/2021.
//

import SwiftUI

struct ContentView: View {
    private var login: Login? = nil
    
    var body: some View {
        if let login = login {
            Text("Token: \(login.token)")
                .padding()
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
    }
}
#endif
