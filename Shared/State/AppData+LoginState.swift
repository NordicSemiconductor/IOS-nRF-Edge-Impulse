//
//  AppData+LoginState.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 16/4/21.
//

import SwiftUI

// MARK: - AppData.LoginState

extension AppData {
    
    enum LoginState {
        case error(_ error: Error)
        case empty
        case loading
        case complete(_ user: User, _ projects: [Project])
    }
}

// MARK: - ViewBuilder

extension AppData.LoginState {
 
    @ViewBuilder
    func view(onRetry: @escaping () -> Void) -> some View {
        switch self {
        case .error(let error):
            VStack(alignment: .center, spacing: 8) {
                ErrorView(error: error)
                Button("Retry", action: onRetry)
                    .modifier(CircularButtonShape(backgroundAsset: .blue))
            }
        case .loading:
            VStack(alignment: .center, spacing: 8) {
                CircularProgressView()
                Text("Loading...")
            }
        default:
            AppHeaderView(.template)
                .frame(maxWidth: 120)
        }
    }
}

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

struct AppDataViewState_Previews: PreviewProvider {
    
    static let loggedInWithoutUser: AppData = {
        let appData = AppData()
        appData.apiToken = "A"
        appData.loginState = .empty
        return appData
    }()
    
    static var previews: some View {
        Group {
            AppData.LoginState.loading
                .view(onRetry: {})
            AppData.LoginState.complete(Preview.previewUser, Preview.previewProjects)
                .view(onRetry: {})
            AppData.LoginState.empty
                .view(onRetry: {})
            AppData.LoginState.error(NordicError(description: "There was en error"))
                .view(onRetry: {})
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
