//
//  ProjectList.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 1/3/21.
//

import SwiftUI
import Combine

struct ProjectList: View {
    @EnvironmentObject var appData: AppData
    
    @State private var listCancellable: Cancellable? = nil
    
    var body: some View {
        NavigationView {
            appData.projectListStatus.view
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Logout") {
                        logoutUser()
                    }
                }
            }
        }
        .setBackgroundColor(Assets.blue)
        .setSingleColumnNavigationViewStyle()
        .background(Color.white)
        .accentColor(.white)
        .onAppear() {
            guard let token = appData.apiToken else { return }
            requestList(with: token)
        }
        .onDisappear() {
            cancelListRequest()
        }
    }
}

// MARK: - API

extension ProjectList {
    
    func requestList(with token: String) {
        let request = APIRequest.listProjects(using: token)
        listCancellable = Network.shared.perform(request, responseType: ProjectsResponse.self)?
            .onUnauthorisedUserError {
                logoutUser()
            }
            .sink(receiveCompletion: { completion in
                guard !Constant.isRunningInPreviewMode else { return }
                switch completion {
                case .failure(let error):
                    appData.projectListStatus = .error(error)
                default:
                    break
                }
            },
            receiveValue: { projectsResponse in
                appData.projectListStatus = .showingProjects(projectsResponse.projects)
            })
        guard !Constant.isRunningInPreviewMode else { return }
        appData.projectListStatus = .loading
    }
    
    func cancelListRequest() {
        listCancellable?.cancel()
    }
    
    func logoutUser() {
        appData.logout()
    }
}

// MARK: - Preview

#if DEBUG
struct ProjectList_Previews: PreviewProvider {
    
    static var previewProjects: [Project]! = {
        let path: String! = Bundle.main.path(forResource: "sample_projects", ofType: "json")
        let content: String! = try? String(contentsOfFile: path)
        let contentData: Data! = content.data(using: .utf8)
        return try? JSONDecoder().decode([Project].self, from: contentData)
    }()
    
    static let projectsPreviewAppData = previewAppData(.showingProjects(previewProjects))
    
    static func previewAppData(_ status: ProjectList.Status) -> AppData {
       let appData = AppData()
        appData.apiToken = "Test"
        appData.projectListStatus = status
        appData.devices = [
            Device(id: UUID()),
            Device(id: UUID()),
            Device(id: UUID())
        ]
        return appData
    }
    
    static var previews: some View {
        Group {
            #if os(iOS)
            ProjectList()
                .previewDevice("iPhone 12 mini")
                .environmentObject(previewAppData(.empty))
            ProjectList()
                .previewDevice("iPhone 12 mini")
                .environmentObject(previewAppData(.error(NordicError(description: "There was en error"))))
            #endif
            ProjectList()
                .preferredColorScheme(.dark)
                .environmentObject(projectsPreviewAppData)
        }
    }
}
#endif
