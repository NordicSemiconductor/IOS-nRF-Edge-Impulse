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
    
    init() {
        setupNavBar(backgroundColor: Assets.blue.uiColor, titleColor: .white)
    }
    
    var body: some View {
        if let token = appData.apiToken {
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
            .accentColor(.white)
            .onAppear() {
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
    
    func setupNavBar(backgroundColor: UIColor, titleColor: UIColor) {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: titleColor
        ]
        
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = attributes
        appearance.largeTitleTextAttributes = attributes
        appearance.backgroundColor = backgroundColor
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
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
        return appData
    }()
    
    static var previewProjects: [Project]! = {
        let path: String! = Bundle.main.path(forResource: "sample_projects", ofType: "json")
        let content: String! = try? String(contentsOfFile: path)
        let contentData: Data! = content.data(using: .utf8)
        return try? JSONDecoder().decode([Project].self, from: contentData)
    }()
    
    static var previews: some View {
        ProjectList()
            .previewDevice("iPhone 12 mini")
            .environmentObject(previewAppData)
    }
}
#endif
