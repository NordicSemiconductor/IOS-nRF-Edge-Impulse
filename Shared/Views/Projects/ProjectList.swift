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
                    Button("Logout") {
                        appData.logout()
                    }
                }
            }
            .onAppear() {
                let request = APIRequest.listProjects(using: token)
                listCancellable = Network.shared.perform(request)?
                    .decode(type: ProjectsResponse.self, decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completition in
                        print(completition)
                    },
                    receiveValue: { projectsResponse in
                        projects = projectsResponse.projects
                        print(projectsResponse.error)
                    })
            }
            .onDisappear() {
                listCancellable?.cancel()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ProjectList_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData())
    }
}
#endif
