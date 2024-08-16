//
//  SignUpView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI
import iOS_Common_Libraries
import AuthenticationServices

// MARK: - SignUpView

struct SignUpView: View {
    
    // MARK: View
    
    var body: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.nordicMiddleGrey)
            
            Button(action: {
                ASWebAuthenticationManager.shared.openSignUpBrowser()
            }) {
                Text("Sign Up")
                    .foregroundColor(.nordicBlue)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SignedUpView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignUpView()
            
            SignUpView()
                .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
