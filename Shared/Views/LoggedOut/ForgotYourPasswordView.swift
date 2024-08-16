//
//  ForgotYourPasswordView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 13/1/22.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - iOS Only View

struct ForgotYourPasswordView: View {
    
    // MARK: View
    
    var body: some View {
        Button(action: {
            
        }) {
            Text("Forgot your password?")
                .foregroundColor(.nordicBlue)
        }
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
