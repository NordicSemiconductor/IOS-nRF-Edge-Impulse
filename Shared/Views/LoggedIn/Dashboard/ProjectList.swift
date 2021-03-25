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
    
    let onRetryButton: () -> Void
    @State private var listCancellable: Cancellable? = nil
    
    var body: some View {
        appData.dashboardViewState.view(onRetry: onRetryButton)
            .frame(minWidth: 295)
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
    
    static let noDevicesAppData: AppData = {
        let appData = AppData()
        appData.dashboardViewState = .showingProjects([ProjectList_Previews.previewProjects[0]])
        appData.devices = []
        return appData
    }()
    
    static func previewAppData(_ status: DashboardView.ViewState) -> AppData {
        let appData = AppData()
        appData.apiToken = "hello"
        appData.user = User(id: 3, username: "independence.day", created: Date())
        appData.dashboardViewState = status
        switch status {
        case .showingProjects(let projects):
            appData.projects = projects
        default:
            appData.projects = []
        }
        appData.devices = [
            Device(name: "Device 1", id: UUID(), rssi: .good),
            Device(name: "Device 2", id: UUID(), rssi: .bad),
            Device(name: "Device 3", id: UUID(), rssi: .ok)
        ]
        return appData
    }
    
    static let doNothingOnRetry: () -> Void = {}
    
    static var previews: some View {
        Group {
            #if os(iOS)
            ProjectList(onRetryButton: doNothingOnRetry)
                .previewDevice("iPhone 12 mini")
                .environmentObject(previewAppData(.loading))
            ProjectList(onRetryButton: doNothingOnRetry)
                .previewDevice("iPhone 12 mini")
                .environmentObject(previewAppData(.empty))
            ProjectList(onRetryButton: doNothingOnRetry)
                .previewDevice("iPhone 12 mini")
                .environmentObject(previewAppData(.error(NordicError(description: "There was en error"))))
            #endif
            ProjectList(onRetryButton: doNothingOnRetry)
                .preferredColorScheme(.dark)
                .environmentObject(projectsPreviewAppData)
        }
    }
}
