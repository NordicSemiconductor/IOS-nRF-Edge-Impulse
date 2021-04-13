//
//  SignedUpView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI

struct SignedUpView: View {
    
    var body: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(Assets.darkGrey.color)
            Link("Sign Up", destination: Constant.signupURL)
                .foregroundColor(Assets.blue.color)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SignedUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignedUpView()
            .previewLayout(.sizeThatFits)
    }
}
#endif
