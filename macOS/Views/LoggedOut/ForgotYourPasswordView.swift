//
//  ForgotYourPasswordView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 13/1/22.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - macOS Only View

struct ForgotYourPasswordView: View {
    
    var body: some View {
        Link("Forgot your password?", destination: Constant.forgottenPasswordURL)
            .foregroundColor(.nordicBlue)
    }
}

#if DEBUG
struct ForgotYourPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForgotYourPasswordView()
                .preferredColorScheme(.light)
            
            ForgotYourPasswordView()
                .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
