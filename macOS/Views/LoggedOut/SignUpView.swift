//
//  SignUpView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 11/1/22.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - SignUpView

struct SignUpView: View {
    
    var body: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.nordicMiddleGrey)
            Link("Sign Up", destination: Constant.signupURL)
                .foregroundColor(.nordicBlue)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SignedUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .previewLayout(.sizeThatFits)
    }
}
#endif
