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
    
    @State var username: String = ""
    @State var password: String = ""
    var isLoginDisabled: Bool {
        username.isEmpty || password.isEmpty
    }
    
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
                        .accentColor(Assets.darkGrey.color)
                    TextField("Username or E-Mail", text: $username)
                        .textCase(.lowercase)
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
                        .accentColor(Assets.darkGrey.color)
                    SecureField("Password", text: $password)
                        .frame(height: 20)
                        .padding()
                        .background(textFieldBackground)
                        .cornerRadius(20)
                        .disableAutocorrection(true)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 16)
                
                if errorMessage.count > 0 {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .frame(width: 25, height: 25)
                            .foregroundColor(Assets.red.color)
                        Text(errorMessage)
                            .foregroundColor(Assets.red.color)
                    }
                }
                
                Button("Login") {
                    attemptLogin()
                }
                .font(.headline)
                .accentColor(.white)
                .frame(width: 80, height: 15)
                .padding()
                .background(isLoginDisabled ?
                                Assets.lightGrey.color : Assets.blue.color)
                .cornerRadius(30)
                .disabled(isLoginDisabled)
                Spacer()
            }
            .navigationTitle("Login")
        }
    }
    
    func attemptLogin() {
        let parameters = LoginParameters(username: username, password: password)
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
