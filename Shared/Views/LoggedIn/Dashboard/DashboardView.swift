//
//  DashboardView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI
import Combine

struct DashboardView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: - State
    
    @State private var userCancellable: Cancellable? = nil
    
    // MARK: - @viewBuilder
    
    var body: some View {
        ZStack {
            appData.dashboardViewState.view(onRetry: requestUser)
                .frame(minWidth: 295)
        }
        .frame(minWidth: 295)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: requestUser, label: {
                    Image(systemName: "arrow.clockwise")
                })
            }
        }
        .onAppear() {
            guard !Constant.isRunningInPreviewMode else { return }
            requestUser()
        }
        .onDisappear() {
            cancelAllRequests()
        }
    }
}

// MARK: - Logic

extension DashboardView {
    
    func requestUser() {
        guard let token = appData.apiToken,
              let httpRequest = HTTPRequest.getUser(using: token) else { return }
        appData.dashboardViewState = .loading
        userCancellable = Network.shared.perform(httpRequest, responseType: GetUserResponse.self)
            .onUnauthorisedUserError {
                appData.logout()
            }
            .sink(receiveCompletion: { completion in
                guard !Constant.isRunningInPreviewMode else { return }
                switch completion {
                case .failure(let error):
                    appData.projects = []
                    appData.dashboardViewState = .error(error)
                default:
                    break
                }
            },
            receiveValue: { userResponse in
                appData.user = userResponse.user
                appData.projects = userResponse.projects
                appData.dashboardViewState = .showingUser(userResponse.user, userResponse.projects)
            })
    }
    
    func cancelAllRequests() {
        userCancellable?.cancel()
    }
}

// MARK: - Preview

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    
    static let loggedInWithoutUser: AppData = {
        let appData = AppData()
        appData.apiToken = "A"
        appData.user = nil
        return appData
    }()
    
    static var previews: some View {
        Group {
            DashboardView()
                .environmentObject(Preview.previewAppData(.loading))
            DashboardView()
                .environmentObject(Preview.projectsPreviewAppData)
            DashboardView()
                .environmentObject(Preview.previewAppData(.empty))
            DashboardView()
                .environmentObject(Preview.previewAppData(.error(NordicError(description: "There was en error"))))
        }
    }
}
#endif
