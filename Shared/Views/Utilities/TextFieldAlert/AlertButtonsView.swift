//
//  AlertButtonsView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/12/21.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - AlertButtonsView

struct AlertButtonsView: View {
    
    private let okFunction: () -> Void
    private let cancelFunction: () -> Void
    
    // MARK: Init
    
    init(okFunction: @escaping () -> Void, cancelFunction: @escaping () -> Void) {
        self.okFunction = okFunction
        self.cancelFunction = cancelFunction
    }
    
    // MARK: View
    
    var body: some View {
        HStack(spacing: 16) {
            Button("OK", action: okFunction)
                .foregroundColor(Color.positiveActionButtonColor)
                .keyboardShortcut(.defaultAction)
            
            Button("Cancel", action: cancelFunction)
                .foregroundColor(Assets.textColor.color)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#if DEBUG
struct AlertButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AlertButtonsView(okFunction: {}, cancelFunction: {})
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
