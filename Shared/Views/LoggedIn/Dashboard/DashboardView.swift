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
        VStack {
            if let user = appData.user {
                UserView(user: user)
                
                Section(header: Text("Projects")) {
                    ProjectList()
                }
            } else {
                Text("No User")
            }
        }
        .frame(minWidth: 295)
        .onAppear() {
            requestUser()
        }
        .onDisappear() {
            cancelUserRequest()
        }
    }
}

// MARK: - Logic

extension DashboardView {
    
    func requestUser() {
        guard let token = appData.apiToken else { return }
        let request = APIRequest.getUser(using: token)
        userCancellable = Network.shared.perform(request, responseType: GetUserResponse.self)?
            .onUnauthorisedUserError {
                appData.logout()
            }
            .sink(receiveCompletion: { completion in
                guard !Constant.isRunningInPreviewMode else { return }
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                default:
                    break
                }
            },
            receiveValue: { projectsResponse in
                guard let user = projectsResponse.user() else {
                    print("Failed")
                    return
                }
                appData.user = user
            })
    }
    
    func cancelUserRequest() {
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
                .environmentObject(DashboardView_Previews.loggedInWithoutUser)
            DashboardView()
                .environmentObject(ProjectList_Previews.projectsPreviewAppData)
        }
    }
}
#endif
