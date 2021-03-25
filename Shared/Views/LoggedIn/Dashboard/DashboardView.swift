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
            ToolbarItem(placement: .cancellationAction) {
                Button(action: logoutUser, label: {
                    Image(systemName: "person.fill.xmark")
                })
            }
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
        guard let token = appData.apiToken else { return }
        appData.dashboardViewState = .loading
        let request = APIRequest.getUser(using: token)
        userCancellable = Network.shared.perform(request, responseType: GetUserResponse.self)?
            .onUnauthorisedUserError {
                logoutUser()
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
            receiveValue: { projectsResponse in
                guard let user = User(response: projectsResponse) else {
                    // TODO.
                    print("Failed")
                    return
                }
                appData.user = user
                appData.projects = projectsResponse.projects
                appData.dashboardViewState = .showingUser(user, projectsResponse.projects)
            })
    }
    
    func logoutUser() {
        appData.logout()
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
                .environmentObject(ProjectList_Previews.previewAppData(.loading))
            DashboardView()
                .environmentObject(ProjectList_Previews.projectsPreviewAppData)
            DashboardView()
                .environmentObject(ProjectList_Previews.previewAppData(.empty))
            DashboardView()
                .environmentObject(ProjectList_Previews.previewAppData(.error(NordicError(description: "There was en error"))))
        }
    }
}
#endif
