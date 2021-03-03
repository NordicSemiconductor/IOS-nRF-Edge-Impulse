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
    private let textFieldBackground = Assets.lightGrey.color.opacity(0.5)
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Spacer()
                Image("EdgeImpulseFull")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .padding(.horizontal, 16)
                HStack(alignment: .lastTextBaseline) {
                    Image(systemName: "person.fill")
                        .frame(width: 40, height: 40)
                        .foregroundColor(Assets.darkGrey.color)
                    TextField("Username or E-Mail", text: $email)
                        .frame(height: 20)
                        .padding()
                        .background(textFieldBackground)
                        .cornerRadius(20)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 16)
                HStack(alignment: .lastTextBaseline) {
                    Image(systemName: "key.fill")
                        .frame(width: 40, height: 40)
                        .foregroundColor(Assets.darkGrey.color)
                    SecureField("Password", text: $password)
                        .frame(height: 20)
                        .padding()
                        .background(textFieldBackground)
                        .cornerRadius(20)
                        .disableAutocorrection(true)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 16)
                Text(errorMessage)
                    .foregroundColor(.red)
                Button("Login") {
                    attemptLogin()
                }
                .disabled(!email.isEmailAddress() || password.isEmpty)
                Spacer()
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
