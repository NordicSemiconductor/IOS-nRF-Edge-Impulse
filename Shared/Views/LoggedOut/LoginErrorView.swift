//
//  LoginErrorView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/4/21.
//

import SwiftUI

struct LoginErrorView: View {
    
    let viewState: NativeLoginView.ViewState
    
    // MARK: - Body
    
    var body: some View {
        switch viewState {
        case .error(let message):
            HStack {
                Image(systemName: "info.circle.fill")
                    .frame(size: .ToolbarImageSize)
                    .foregroundColor(Assets.red.color)
                Text(message)
                    .foregroundColor(Assets.red.color)
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct LoginErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginErrorView(viewState: .clean)
            LoginErrorView(viewState: .error("Test Error."))
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
