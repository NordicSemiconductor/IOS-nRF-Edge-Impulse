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
    @State var errorMessage: String = ""
    
    @State private var loginCancellable: Cancellable? = nil
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                HStack {
                    Text("E-mail")
                    TextField("nordic@edgeimpulse.com", text: $email)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 16)
                HStack {
                    Text("Password")
                    SecureField("1234", text: $password)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 16)
                Text(errorMessage)
                    .foregroundColor(.red)
                Button("Login") {
                    attemptLogin()
                }
                .disabled(!email.isEmailAddress() || password.isEmpty)
            }
            .navigationTitle("Login")
        }
    }
    
    func attemptLogin() {
        let parameters = LoginParameters(username: email, password: password)
        guard let request = APIRequest.login(parameters) else {
            // Show error.
            return
        }
        loginCancellable = Network.shared.perform(request, responseType: LoginResponse.self)?
            .sink(receiveCompletion: { _ in }, receiveValue: { loginResponse in
                guard loginResponse.success else {
                    errorMessage = loginResponse.error ?? ""
                    return
                }
                appData.apiToken = loginResponse.token
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
