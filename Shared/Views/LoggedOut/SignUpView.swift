//
//  SignUpView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI
import BetterSafariView

struct SignUpView: View {
    
    // MARK: - Properties
    
    @State private var showSafariView = false
    
    private let safariViewConfiguration =
        SafariView.Configuration(entersReaderIfAvailable: false, barCollapsingEnabled: true)
    
    // MARK: - View
    
    var body: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(Assets.middleGrey.color)
            
            Button(action: {
                showSafariView = true
            }) {
                Text("Sign Up")
                    .foregroundColor(Assets.blue.color)
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
