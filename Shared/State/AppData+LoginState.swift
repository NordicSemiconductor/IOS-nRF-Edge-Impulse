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
        case showingUser(_ user: User, _ projects: [Project])
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
                    .circularButtonShape(backgroundAsset: .blue)
            }
        case .empty:
            VStack(alignment: .center, spacing: 16) {
                Image(systemName: "moon.stars.fill")
                    .resizable()
                    .frame(width: 90, height: 90, alignment: .center)
                    .foregroundColor(Assets.blueslate.color)
                Text("Your Project List is empty.")
            }
        case .loading:
            VStack(alignment: .center, spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Loading...")
            }
        case .showingUser(_, _):
            AppHeaderView(.template)
                .frame(maxWidth: 120)
        }
    }
}

// MARK: - Preview

#if DEBUG
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
            AppData.LoginState.showingUser(Preview.previewUser, Preview.previewProjects)
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
