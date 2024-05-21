//
//  NativeLoginView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/2/21.
//

import SwiftUI
import Combine
import Introspect
import iOS_Common_Libraries

struct NativeLoginView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - EnvironmentObject(s)
    
    @EnvironmentObject var appData: AppData
    
    // MARK: - State
    
    @State var username: String = ""
    @State var password: String = ""
    
    @State private var viewState: ViewState = .clean
    @State private var loginCancellable: Cancellable? = nil
    
    // MARK: - Properties
    
    private let textFieldBackground = Color.nordicLightGrey.opacity(0.5)
    
    // MARK: - FocusedField
    
    #if os(iOS)
    @FocusState private var focusedField: Field?
    
    private enum Field: Int, Hashable {
        case username, password
    }
    #endif
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            AppHeaderView()
            
            #if os(iOS)
            UsernameField($username, enabled: !isMakingRequest)
                .frame(maxWidth: .maxTextFieldWidth)
                .padding(.horizontal, 16)
                .focused($focusedField, equals: .username)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .password
                }
            #else
            UsernameField($username, enabled: !isMakingRequest)
                .frame(maxWidth: .maxTextFieldWidth)
                .padding(.horizontal, 16)
                .introspectTextField { textField in
                    textField.becomeFirstResponder()
                }
            #endif
            
            #if os(iOS)
            HStack(alignment: .lastTextBaseline) {
                Image(systemName: "key.fill")
                    .frame(size: .StandardImageSize)
                    .accentColor(.nordicDarkGrey)
                
                PasswordField(binding: $password, enabled: !isMakingRequest)
                    .foregroundColor(.textFieldColor)
                    .modifier(RoundedTextFieldShape(colorScheme == .light ? .nordicLightGrey : .nordicMiddleGrey))
                    .padding(.vertical, 8)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.done)
                    .onSubmit {
                        attemptLogin()
                    }
            }
            .frame(maxWidth: .maxTextFieldWidth)
            .padding(.horizontal, 16)
            #else
            PasswordField(binding: $password, enabled: !isMakingRequest)
                .frame(maxWidth: .maxTextFieldWidth)
                .padding(.horizontal, 16)
            #endif
            
            LoginErrorView(viewState: viewState)
            
            VStack {
                switch viewState {
                case .makingRequest:
                    CircularProgressView()
                default:
                    ForgotYourPasswordView()
                    
                    Button("Login") {
                        attemptLogin()
                    }
                    .keyboardShortcut(.defaultAction)
                    .modifier(CircularButtonShape(backgroundColor: isLoginButtonDisabled ? .nordicDarkGrey : .nordicBlue))
                    .disabled(isLoginButtonDisabled)
                }
            }
            .padding(.vertical, 8)
            
            SignUpView()
            
            Spacer()
        }
        #if os(iOS)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.focusedField = .username
            }
        }
        #endif
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
