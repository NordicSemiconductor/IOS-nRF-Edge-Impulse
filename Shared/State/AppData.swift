//
//  AppData.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 1/3/21.
//

import Foundation
import KeychainSwift
import Combine

final class AppData: ObservableObject {
    
    // MARK: - Public Properties
    
    @Published var apiToken: String? {
        didSet {
            if let token = apiToken {
                guard !Constant.isRunningInPreviewMode else { return }
                keychain.set(token, forKey: KeychainKeys.apiToken.rawValue)
            } else {
                keychain.delete(KeychainKeys.apiToken.rawValue)
            }
        }
    }
    
    @Published var loginState: AppData.LoginState = .empty
    
    @Published var selectedProject: Project? {
        didSet {
            selectedProjectDidChange()
        }
    }
    @Published var selectedTab: Tabs? = .Devices
    
    @Published var projectDevelopmentKeys: [Project: ProjectDevelopmentKeysResponse]
    @Published var samplesForCategory: [DataSample.Category: [DataSample]]
    
    // MARK: - Private Properties
    
    private lazy var keychain = KeychainSwift()
    internal var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        self.projectDevelopmentKeys = [Project: ProjectDevelopmentKeysResponse]()
        self.samplesForCategory = [DataSample.Category: [DataSample]]()
        self.apiToken = keychain.get(KeychainKeys.apiToken.rawValue)
    }
    
    // MARK: - API
    
    var isLoggedIn: Bool { apiToken != nil }
    
    var user: User? {
        switch loginState {
        case .complete(let user, _):
            return user
        default:
            return nil
        }
    }
    
    var projects: [Project]? {
        switch loginState {
        case .complete(_, let projects):
            return projects
        default:
            return nil
        }
    }
    
    func logout() {
        apiToken = nil
        loginState = .empty
        selectedProjectDidChange()
    }
}

private extension AppData {
    
    func selectedProjectDidChange() {
        projectDevelopmentKeys = [Project: ProjectDevelopmentKeysResponse]()
        samplesForCategory = [:]
        requestDataSamples()
    }
}

// MARK: - KeychainKeys

private extension AppData {
    
    enum KeychainKeys: String, RawRepresentable {
        case apiToken
    }
}
