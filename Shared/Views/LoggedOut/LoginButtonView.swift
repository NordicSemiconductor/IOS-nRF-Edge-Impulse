//
//  LoginButtonView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 13/8/24.
//

import SwiftUI

// MARK: - LoginButtonView

struct LoginButtonView: View {
    
    let viewState: NativeLoginView.ViewState
    let loginDisabled: Bool
    let loginAction: () -> Void
    
    // MARK: View
    
    var body: some View {
        VStack {
            switch viewState {
            case .makingRequest:
                CircularProgressView()
            default:
                ForgotYourPasswordView()
                
                Button("Login", action: loginAction)
                .keyboardShortcut(.defaultAction)
                .modifier(CircularButtonShape(backgroundColor: loginDisabled ? .nordicDarkGrey : .nordicBlue))
                .disabled(loginDisabled)
            }
        }
        .padding(.vertical, 8)
    }
}
