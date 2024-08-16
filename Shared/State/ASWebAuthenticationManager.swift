//
//  AppData+Auth.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 16/8/24.
//

import Foundation
import AuthenticationServices
import iOS_Common_Libraries

// MARK: - ASWebAuthenticationManager

final class ASWebAuthenticationManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    // MARK: Singleton
    
    static let shared = ASWebAuthenticationManager()
    
    private override init() {}
    
    // MARK: openForgotYourPassword
    
    func openForgotYourPassword() {
        let session = ASWebAuthenticationSession(url: Constant.forgottenPasswordURL, callbackURLScheme: nil) { _, _ in
            // No-op.
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    // MARK: openSignUpBrowser
    
    func openSignUpBrowser() {
        let session = ASWebAuthenticationSession(url: Constant.signupURL, callbackURLScheme: nil) { _, _ in
            // No-op.
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

// MARK: - URL(s)

extension Constant {
    
    static let signupURL: URL! = URL(string: "https://studio.edgeimpulse.com/signup")
    static let forgottenPasswordURL: URL! = URL(string: "https://studio.edgeimpulse.com/forgot-password")
}
