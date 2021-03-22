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
        ZStack {
            appData.projectsViewState.view(onRetry: {
                refreshList()
            })
            .frame(minWidth: 295)
            .setTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: logoutUser, label: {
                        Image(systemName: "person.fill.xmark")
                    })
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: refreshList, label: {
                        Image(systemName: "arrow.clockwise")
                    })
                }
            }
        }
        .onAppear() {
            refreshList()
        }
        .onDisappear() {
            cancelListRequest()
        }
    }
}

// MARK: - API

extension ProjectList {
    
    func refreshList() {
        guard let token = appData.apiToken else { return }
        let request = APIRequest.listProjects(using: token)
        listCancellable = Network.shared.perform(request, responseType: ProjectsResponse.self)?
            .onUnauthorisedUserError {
                logoutUser()
            }
            .sink(receiveCompletion: { completion in
                guard !Constant.isRunningInPreviewMode else { return }
                switch completion {
                case .failure(let error):
                    appData.projects = []
                    appData.projectsViewState = .error(error)
                default:
                    break
                }
            },
            receiveValue: { projectsResponse in
                appData.projects = projectsResponse.projects
                appData.projectsViewState = .showingProjects(projectsResponse.projects)
            })
        guard !Constant.isRunningInPreviewMode else { return }
        appData.projectsViewState = .loading
    }
    
    func cancelListRequest() {
        listCancellable?.cancel()
    }
    
    func logoutUser() {
        appData.logout()
    }
}

// MARK: - Preview

struct ProjectList_Previews: PreviewProvider {
    
    static var previewProjects: [Project]! = {
        let path: String! = Bundle.main.path(forResource: "sample_projects", ofType: "json")
        let content: String! = try? String(contentsOfFile: path)
        let contentData: Data! = content.data(using: .utf8)
        return try? JSONDecoder().decode([Project].self, from: contentData)
    }()
    
    static let projectsPreviewAppData = previewAppData(.showingProjects(previewProjects))
    
    static func previewAppData(_ status: ProjectList.ViewState) -> AppData {
       let appData = AppData()
        appData.projectsViewState = status
        switch status {
        case .showingProjects(let projects):
            appData.projects = projects
        default:
            appData.projects = []
        }
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
                .environmentObject(previewAppData(.loading))
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
