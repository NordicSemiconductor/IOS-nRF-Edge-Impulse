//
//  ForgotYourPasswordView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 13/1/22.
//

import SwiftUI
import BetterSafariView
import iOS_Common_Libraries

// MARK: - iOS Only View

struct ForgotYourPasswordView: View {
    
    // MARK: - Properties
    
    @State private var showSafariView = false
    
    private let safariViewConfiguration =
        SafariView.Configuration(entersReaderIfAvailable: false, barCollapsingEnabled: true)
    
    // MARK: - View
    
    var body: some View {
        Button(action: {
            showSafariView = true
        }) {
            Text("Forgot your password?")
                .foregroundColor(.nordicBlue)
        }
        .safariView(isPresented: $showSafariView) {
            SafariView(url: Constant.forgottenPasswordURL, configuration: safariViewConfiguration)
                .dismissButtonStyle(.done)
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
