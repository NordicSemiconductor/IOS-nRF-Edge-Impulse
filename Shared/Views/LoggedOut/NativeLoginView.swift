//
//  NativeLoginView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/2/21.
//

import SwiftUI
import Combine

struct NativeLoginView: View {
    // MARK: - EnvironmentObject(s)
    
    @EnvironmentObject var appData: AppData
    
    // MARK: - State
    
    @State var username: String = ""
    @State var password: String = ""
    @State var errorMessage: String = ""
    
    @State private var loginCancellable: Cancellable? = nil
    
    // MARK: - Properties
    
    private let textFieldBackground = Assets.lightGrey.color.opacity(0.5)
    
    var isLoginDisabled: Bool {
        username.isEmpty || password.isEmpty
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack(alignment: .center, spacing: 16) {
                Image("Nordic")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                Image("EdgeImpulse")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
            }
            HStack(alignment: .lastTextBaseline) {
                Image(systemName: "person.fill")
                    .frame(width: 40, height: 40)
                    .accentColor(Assets.darkGrey.color)
                TextField("Username or E-Mail", text: $username)
                    .foregroundColor(.black)
                    .roundedTextFieldShape(backgroundAsset: .lightGrey, hasTextFieldBelow: true)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 16)
            HStack(alignment: .lastTextBaseline) {
                Image(systemName: "key.fill")
                    .frame(width: 40, height: 40)
                    .accentColor(Assets.darkGrey.color)
                SecureField("Password", text: $password)
                    .foregroundColor(.black)
                    .roundedTextFieldShape(backgroundAsset: .lightGrey)
                    .disableAutocorrection(true)
                    .padding(.bottom, 8)
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
                .padding(.bottom, 8)
            }
            
            Link("Forgot your password?", destination: Constant.forgottenPasswordURL)
                .foregroundColor(Assets.blue.color)
                .padding(.bottom, 8)
            
            Button("Login") {
                attemptLogin()
            }
            .circularButtonShape(backgroundAsset: isLoginDisabled ? .lightGrey : .blue)
            .disabled(isLoginDisabled)
            .padding(.bottom, 8)
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(Assets.darkGrey.color)
                Link("Sign Up", destination: Constant.signupURL)
                    .foregroundColor(Assets.blue.color)
            }
            
            Spacer()
        }
    }
    
    func attemptLogin() {
        let parameters = LoginParameters(username: username, password: password)
        guard let httpRequest = HTTPRequest.login(parameters) else {
            // Show error.
            return
        }
        loginCancellable = Network.shared.perform(httpRequest, responseType: LoginResponse.self)?
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
        Group {
            NativeLoginView()
                .preferredColorScheme(.light)
        }
        #if os(iOS)
        Group {
            NativeLoginView()
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
                .preferredColorScheme(.dark)
        }
        #endif
    }
}
#endif
