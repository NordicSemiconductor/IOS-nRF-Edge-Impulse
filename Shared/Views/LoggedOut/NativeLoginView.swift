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
    
    @State private var viewState: ViewState = .clean
    @State private var loginCancellable: Cancellable? = nil
    
    // MARK: - Properties
    
    private let textFieldBackground = Assets.lightGrey.color.opacity(0.5)
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            AppHeaderView()
            
            UsernameField($username, enabled: !isMakingRequest)
                .padding(.horizontal, 16)
            
            PasswordField($password, enabled: !isMakingRequest)
                .padding(.horizontal, 16)
            
            switch viewState {
            case .error(let message):
                HStack {
                    Image(systemName: "info.circle.fill")
                        .frame(size: .ToolbarImageSize)
                        .foregroundColor(Assets.red.color)
                    Text(message)
                        .foregroundColor(Assets.red.color)
                }
                .padding(.bottom, 8)
            default:
                Text("")
            }
            
            VStack {
                switch viewState {
                case .makingRequest:
                    ProgressView()
                        .foregroundColor(.accentColor)
                        .progressViewStyle(CircularProgressViewStyle())
                default:
                    Link("Forgot your password?", destination: Constant.forgottenPasswordURL)
                        .foregroundColor(Assets.blue.color)
                        
                    
                    Button("Login") {
                        attemptLogin()
                    }
                    .keyboardShortcut(.defaultAction)
                    .circularButtonShape(backgroundAsset: isLoginButtonDisabled ? .lightGrey : .blue)
                    .disabled(isLoginButtonDisabled)
                }
            }
            .padding(.vertical, 8)
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(Assets.darkGrey.color)
                Link("Sign Up", destination: Constant.signupURL)
                    .foregroundColor(Assets.blue.color)
            }
            
            Spacer()
        }
    }
}

// MARK: - Logic

fileprivate extension NativeLoginView {
    
    var isLoginButtonDisabled: Bool {
        !isMakingRequest && (username.isEmpty || password.isEmpty)
    }
    
    var isMakingRequest: Bool {
        switch viewState {
        case .makingRequest:
            return true
        default:
            return false
        }
    }
    
    func attemptLogin() {
        let parameters = LoginParameters(username: username, password: password)
        guard let httpRequest = HTTPRequest.login(parameters) else {
            // Show error.
            return
        }
        loginCancellable = Network.shared.perform(httpRequest, responseType: LoginResponse.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    viewState = .error(error.localizedDescription)
                default:
                    break
                }
            }, receiveValue: { loginResponse in
                guard loginResponse.success else {
                    viewState = .error(loginResponse.error ?? "")
                    return
                }
                appData.apiToken = loginResponse.token
            })
        viewState = .makingRequest
    }
}

// MARK: - ViewState

fileprivate extension NativeLoginView {
    
    enum ViewState {
        case clean
        case makingRequest
        case error(_ message: String)
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
