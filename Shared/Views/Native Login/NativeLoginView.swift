//
//  NativeLoginView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/2/21.
//

import SwiftUI

struct NativeLoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("E-mail")
                TextField("nordic@edgeimpulse.com", text: $email)
                    .keyboardType(.emailAddress)
            }
            HStack {
                Text("Password")
                SecureField("1234", text: $password)
                    .disableAutocorrection(true)
            }
            Button("Login") {
                // Send Login Request.
            }
            .disabled(!email.isEmailAddress() || password.isEmpty)
        }
        .navigationTitle("Login")
        .padding()
    }
}

// MARK: - Preview

#if DEBUG
struct NativeLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NativeLoginView()
    }
}
#endif
