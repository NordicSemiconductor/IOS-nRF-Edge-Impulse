//
//  NativeLoginView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/2/21.
//

import SwiftUI
import Combine

struct NativeLoginView: View {
    @EnvironmentObject var appData: AppData
    
    @State var email: String = ""
    @State var password: String = ""
    
    @State private var loginCancellable: Cancellable? = nil
    
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
                attemptLogin()
            }
            .disabled(!email.isEmailAddress() || password.isEmpty)
        }
        .navigationTitle("Login")
        .padding()
    }
    
    func attemptLogin() {
        let parameters = LoginParameters(username: email, password: password)
        guard let request = LoginRequest(parameters) else {
            // Show error.
            return
        }
        loginCancellable = Network.shared.perform(request)
            .decode(type: Login.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: {    
                print ("Received completion: \($0).")
            },
            receiveValue: { user in
                print ("Received user: \(user.token).")
                appData.apiToken = user.token
            })
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
