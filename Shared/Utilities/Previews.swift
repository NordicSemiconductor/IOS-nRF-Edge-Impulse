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
        appData.dashboardViewState = .showingUser(previewUser, [Preview.previewProjects[0]])
        return appData
    }()
    
    static let noDevicesDeviceData: DeviceData = {
        let deviceData = DeviceData()
        deviceData.scanResults = []
        return deviceData
    }()
    
    static func previewAppData(_ viewState: DashboardView.ViewState) -> AppData {
        let appData = AppData()
        appData.apiToken = "hello"
        appData.dashboardViewState = viewState
        switch viewState {
        case .showingUser(let user, let projects):
            appData.user = user
            appData.projects = projects
        default:
            appData.user = nil
            appData.projects = []
        }
        return appData
    }
    
    static var mockDevicedDeviceData: DeviceData = {
        let deviceData = DeviceData()
        deviceData.scanResults = [
            Device(name: "Device 1", id: UUID(), rssi: .good, advertisementData: .mock),
            Device(name: "Device 2", id: UUID(), rssi: .bad, advertisementData: .mock),
            Device(name: "Device 3", id: UUID(), rssi: .ok, advertisementData: .mock)
        ]
        return deviceData
    }()
}
#endif
