//
//  Previews.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/3/21.
//

import Foundation

#if DEBUG
struct Preview {
    
    // MARK: - AppData
    
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
        return appData
    }()
    
    static func previewAppData(_ loginState: AppData.LoginState) -> AppData {
        let appData = AppData()
        appData.apiToken = "hello"
        appData.loginState = loginState
        return appData
    }
    
    // MARK: - DeviceData
    
    static let noDevicesDeviceData: DeviceData = {
        let deviceData = DeviceData()
        deviceData.isScanning = false
        deviceData.scanResults = []
        return deviceData
    }()
    
    static let isScanningButNoDevicesDeviceData: DeviceData = {
        let deviceData = DeviceData()
        deviceData.isScanning = true
        deviceData.scanResults = []
        return deviceData
    }()

    static var mockDevicedDeviceData: DeviceData = {
        let deviceData = DeviceData()
        deviceData.isScanning = false
        deviceData.scanResults = [
            Device(name: "Device 1", id: UUID(), rssi: .good, advertisementData: .mock),
            Device(name: "Device 2", id: UUID(), rssi: .bad, advertisementData: .mock),
            Device(name: "Device 3", id: UUID(), rssi: .ok, advertisementData: .mock)
        ]
        return deviceData
    }()
}
#endif
