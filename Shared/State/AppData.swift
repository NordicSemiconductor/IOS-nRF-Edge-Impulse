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
            if let newToken = apiToken {
                keychain.write(newToken)
            } else {
                keychain.remove()
            }
        }
    }
    
    @Published var loginState: AppData.LoginState = .empty
    
    @Published var selectedProject: Project? = Project.Unselected {
        didSet {
            selectedProjectDidChange()
        }
    }
    @Published var selectedTab: Tabs? = .Devices
    
    @Published var projectDevelopmentKeys: [Project: ProjectDevelopmentKeysResponse]
    @Published var projectSocketTokens: [Project: Token]
    
    @Published var samplesForCategory: [DataSample.Category: [DataSample]]
    @Published var selectedCategory: DataSample.Category = .training
    @Published internal var dataAquisitionViewState = DataAcquisitionViewState()
    @Published internal var inferencingViewState = InferencingViewState()
    
    // MARK: - Private Properties
    
    private lazy var keychain = KeychainSwift(keyPrefix: Constant.appName)
    internal var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        self.projectDevelopmentKeys = [Project: ProjectDevelopmentKeysResponse]()
        self.projectSocketTokens = [Project: Token]()
        self.samplesForCategory = [DataSample.Category: [DataSample]]()
        self.apiToken = keychain.get("apiToken")
        
        // If inferencingViewState changes, make sure appData 'fires' as if a change has happened,
        // to alert InferencingView.
        inferencingViewState.objectWillChange
            .sink(receiveValue: { self.objectWillChange.send() })
            .store(in: &cancellables)
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
        selectedProject = Project.Unselected
        projectSocketTokens = [Project: Token]()
        apiToken = nil
        loginState = .empty
        selectedProjectDidChange()
    }
}

// MARK: - AppData

fileprivate extension AppData {
    
    func selectedProjectDidChange() {
        projectDevelopmentKeys = [Project: ProjectDevelopmentKeysResponse]()
        samplesForCategory = [:]
        requestDataSamples()
        requestSelectedProjectSocketToken()
    }
}

// MARK: - KeychainSwift Helpers

fileprivate extension KeychainSwift {
    
    func read(key: String = #function) -> String? {
        get(key)
    }
    
    func write(_ value: String, key: String = #function) {
        guard !Constant.isRunningInPreviewMode else { return }
        set(value, forKey: key)
    }
    
    func remove(key: String = #function) {
        delete(key)
    }
}
