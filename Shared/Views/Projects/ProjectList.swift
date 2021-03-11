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
            List {
                ForEach(appData.projects) { project in
                    NavigationLink(destination: DataAcquisitionView(project: project)) {
                        ProjectRow(project: project)
                            .listRowInsets(EdgeInsets())
                    }
                    .tag(project)
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Logout") {
                        logoutUser()
                    }
                }
            }
        }
        .setSingleColumnNavigationViewStyle()
        .accentColor(.white)
        .onAppear() {
//            setupNavBar(backgroundColor: Assets.blue, titleColor: .white)
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
            .sink(receiveCompletion: { completition in
                print(completition)
            },
            receiveValue: { projectsResponse in
                appData.projects = projectsResponse.projects
                print(projectsResponse.error)
            })
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
    
    static var previewAppData: AppData = {
       var appData = AppData()
        appData.apiToken = "Test"
        appData.projects = previewProjects
        appData.devices = [
            Device(id: UUID()),
            Device(id: UUID()),
            Device(id: UUID())
        ]
        return appData
    }()
    
    static var previewProjects: [Project]! = {
        let path: String! = Bundle.main.path(forResource: "sample_projects", ofType: "json")
        let content: String! = try? String(contentsOfFile: path)
        let contentData: Data! = content.data(using: .utf8)
        return try? JSONDecoder().decode([Project].self, from: contentData)
    }()
    
    static var previews: some View {
        Group {
            #if os(iOS)
            ProjectList()
                .previewDevice("iPhone 12 mini")
                .environmentObject(previewAppData)
            #endif
            ProjectList()
                .environmentObject(previewAppData)
        }
    }
}
#endif
