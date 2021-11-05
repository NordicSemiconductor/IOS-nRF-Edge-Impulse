//
//  NativeLoginView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/2/21.
//

import SwiftUI
import Combine
import Introspect

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
    
    private enum Field: Int, Hashable {
        case username, password
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    @FocusState private var focusedField: Field?
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            AppHeaderView()
            
            if #available(iOS 15.0, macOS 12.0, *) {
                UsernameField($username, enabled: !isMakingRequest)
                    .frame(maxWidth: .maxTextFieldWidth)
                    .padding(.horizontal, 16)
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
            } else {
                UsernameField($username, enabled: !isMakingRequest)
                    .frame(maxWidth: .maxTextFieldWidth)
                    .padding(.horizontal, 16)
                    .introspectTextField { textField in
                        textField.becomeFirstResponder()
                    }
            }
            
            if #available(iOS 15.0, macOS 12.0, *) {
                PasswordField($password, enabled: !isMakingRequest)
                    .frame(maxWidth: .maxTextFieldWidth)
                    .padding(.horizontal, 16)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.done)
                    .onSubmit {
                        attemptLogin()
                    }
            } else {
                PasswordField($password, enabled: !isMakingRequest)
                    .frame(maxWidth: .maxTextFieldWidth)
                    .padding(.horizontal, 16)
            }
            
            LoginErrorView(viewState: viewState)
            
            VStack {
                switch viewState {
                case .makingRequest:
                    CircularProgressView()
                default:
                    Link("Forgot your password?", destination: Constant.forgottenPasswordURL)
                        .foregroundColor(Assets.blue.color)
                        
                    
                    Button("Login") {
                        attemptLogin()
                    }
                    .keyboardShortcut(.defaultAction)
                    .modifier(CircularButtonShape(backgroundAsset: isLoginButtonDisabled ? .lightGrey : .blue))
                    .disabled(isLoginButtonDisabled)
                }
            }
            .padding(.vertical, 8)
            
            SignedUpView()
            
            Spacer()
        }
        .onAppear() {
            guard #available(iOS 15.0, macOS 12.0, *) else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.focusedField = .username
            }
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
        let lowercaseUsername = username.lowercased(with: .current)
        let parameters = LoginParameters(username: lowercaseUsername,
                                         password: password)
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

internal extension NativeLoginView {
    
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
