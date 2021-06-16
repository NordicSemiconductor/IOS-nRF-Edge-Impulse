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
    
    static var previewUser = User(id: 3, username: "independence.day", name: "ID4", created: Date())
    
    static var previewProjects: [Project]! = {
        let path: String! = Bundle.main.path(forResource: "sample_projects", ofType: "json")
        let content: String! = try? String(contentsOfFile: path)
        let contentData: Data! = content.data(using: .utf8)
        return try? JSONDecoder().decode([Project].self, from: contentData)
    }()
    
    static let previewDataSamples: [DataSample]! = {
        let path: String! = Bundle.main.path(forResource: "sample_datasamples", ofType: "json")
        let content: String! = try? String(contentsOfFile: path)
        let contentData: Data! = content.data(using: .utf8)
        return try? JSONDecoder().decode([DataSample].self, from: contentData)
    }()
    
    static let projectsPreviewAppData = previewAppData(.complete(previewUser, previewProjects))
    
    static let noDevicesAppData: AppData = {
        let appData = AppData()
        appData.loginState = .complete(previewUser, Preview.previewProjects)
        return appData
    }()
    
    static let noProjectsAppData: AppData = {
        let appData = AppData()
        appData.loginState = .complete(previewUser, [])
        return appData
    }()
    
    static func previewAppData(_ loginState: AppData.LoginState) -> AppData {
        let appData = AppData()
        appData.apiToken = "hello"
        appData.loginState = loginState
        appData.samplesForCategory[.training] = previewDataSamples
        return appData
    }
}
#endif
