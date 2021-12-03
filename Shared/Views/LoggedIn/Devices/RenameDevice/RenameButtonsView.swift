//
//  RenameButtonsView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/12/21.
//

import SwiftUI

// MARK: - RenameButtonsView

struct RenameButtonsView: View {
    
    private var viewState: RenameDeviceView.ViewState
    private let enabled: Bool
    private let okFunction: () -> Void
    private let cancelFunction: () -> Void
    
    // MARK: Init
    
    init(_ viewState: RenameDeviceView.ViewState, enabled: Bool, okFunction: @escaping () -> Void,
         cancelFunction: @escaping () -> Void) {
        self.viewState = viewState
        self.enabled = enabled
        self.okFunction = okFunction
        self.cancelFunction = cancelFunction
    }
    
    // MARK: View
    
    var body: some View {
        HStack(spacing: 16) {
            Button("OK", action: okFunction)
                .foregroundColor(.positiveActionButtonColor)
                .disabled(!enabled)
                .keyboardShortcut(.defaultAction)
            
            switch viewState {
            case .waitingForInput:
                Button("Cancel", action: cancelFunction)
                    .foregroundColor(.textColor)
                    .disabled(!enabled)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#if DEBUG
struct RenameButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RenameButtonsView(.waitingForInput, enabled: true, okFunction: {}, cancelFunction: {})
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
