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
            Text("Hello, World!")
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
                print("Got User \(user.username)")
            })
    }
    
    func cancelUserRequest() {
        userCancellable?.cancel()
    }
}

// MARK: - Preview

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(ProjectList_Previews.projectsPreviewAppData)
    }
}
#endif
