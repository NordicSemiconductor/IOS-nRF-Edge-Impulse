//
//  Previews.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/3/21.
//

import Foundation

#if DEBUG
struct Preview {
    static var previewUser = User(id: 3, username: "independence.day", created: Date())
    
    static var previewProjects: [Project]! = {
        let path: String! = Bundle.main.path(forResource: "sample_projects", ofType: "json")
        let content: String! = try? String(contentsOfFile: path)
        let contentData: Data! = content.data(using: .utf8)
        return try? JSONDecoder().decode([Project].self, from: contentData)
    }()
    
    static let projectsPreviewAppData = previewAppData(.showingUser(previewUser, previewProjects))
    
    static let noDevicesAppData: AppData = {
        let appData = AppData()
        appData.loginState = .showingUser(previewUser, [Preview.previewProjects[0]])
        appData.scanResults = []
        return appData
    }()
    
    static func previewAppData(_ loginState: AppData.LoginState) -> AppData {
        let appData = AppData()
        appData.apiToken = "hello"
        appData.loginState = loginState
        switch loginState {
        case .showingUser(_, let projects):
            appData.projects = projects
        default:
            appData.projects = []
        }
        appData.scanResults = [
            ScanResult(name: "Device 1", id: UUID(), rssi: .good, advertisementData: .mock),
            ScanResult(name: "Device 2", id: UUID(), rssi: .bad, advertisementData: .mock),
            ScanResult(name: "Device 3", id: UUID(), rssi: .ok, advertisementData: .mock)
        ]
        return appData
    }
}
#endif
