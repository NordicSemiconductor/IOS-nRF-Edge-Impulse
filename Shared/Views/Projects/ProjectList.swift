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
    
    @State private var projects: [Project] = []
    @State private var listCancellable: Cancellable? = nil
    
    var body: some View {
        if let token = appData.apiToken {
            NavigationView {
                List {
                    ForEach(projects) { project in
                        ProjectRow(project: project)
                    }
                }
                .navigationTitle("Projects")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Logout") {
                            logoutUser()
                        }
                    }
                }
            }
            .accentColor(.white)
            .onAppear() {
                setupNavBar()
                requestList(with: token)
            }
            .onDisappear() {
                cancelListRequest()
            }
        }
    }
}

// MARK: - API

extension ProjectList {
    
    func setupNavBar() {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = attributes
        appearance.largeTitleTextAttributes = attributes
        appearance.backgroundColor = Assets.blue.uiColor
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
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
                projects = projectsResponse.projects
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
        return appData
    }()
    
    static var previews: some View {
        ProjectList()
            .environmentObject(previewAppData)
    }
}
#endif
