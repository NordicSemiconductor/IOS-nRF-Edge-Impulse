//
//  SignUpView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI
import BetterSafariView
import iOS_Common_Libraries

struct SignUpView: View {
    
    // MARK: - Properties
    
    @State private var showSafariView = false
    
    private let safariViewConfiguration =
        SafariView.Configuration(entersReaderIfAvailable: false, barCollapsingEnabled: true)
    
    // MARK: - View
    
    var body: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.nordicMiddleGrey)
            
            Button(action: {
                showSafariView = true
            }) {
                Text("Sign Up")
                    .foregroundColor(.nordicBlue)
            }
            .safariView(isPresented: $showSafariView) {
                SafariView(url: Constant.signupURL, configuration: safariViewConfiguration)
                    .dismissButtonStyle(.done)
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
