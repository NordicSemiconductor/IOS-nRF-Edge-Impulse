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
    
    @Published var selectedProject: Project? = Project.Unselected {
        didSet {
            selectedProjectDidChange()
        }
    }
    @Published var selectedTab: Tabs? = .Devices
    
    @Published var projectDevelopmentKeys: [Project: ProjectDevelopmentKeysResponse]
    @Published var projectSocketTokens: [Project: Token]
    @Published var samplesForCategory: [DataSample.Category: [DataSample]]
    
    // MARK: - Private Properties
    
    private lazy var keychain = KeychainSwift(keyPrefix: Constant.appName)
    internal var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        self.projectDevelopmentKeys = [Project: ProjectDevelopmentKeysResponse]()
        self.projectSocketTokens = [Project: Token]()
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
        selectedProject = Project.Unselected
        projectSocketTokens = [Project: Token]()
        apiToken = nil
        loginState = .empty
        selectedProjectDidChange()
    }
}

// MARK: - Requests

extension AppData {
    
    func deleteDevice(_ device: RegisteredDevice, onSuccess callback: @escaping () -> Void) {
        guard let currentProject = selectedProject, let apiToken = apiToken,
              let deleteRequest = HTTPRequest.deleteDevice(device, from: currentProject, using: apiToken) else { return }

        Network.shared.perform(deleteRequest, responseType: DeleteDeviceResponse.self)
            .sinkOrRaiseAppEventError { _ in
                callback()
            }
            .store(in: &cancellables)
    }
}

private extension AppData {
    
    func selectedProjectDidChange() {
        projectDevelopmentKeys = [Project: ProjectDevelopmentKeysResponse]()
        samplesForCategory = [:]
        requestDataSamples()
        requestSelectedProjectSocketToken()
    }
}

// MARK: - KeychainKeys

private extension AppData {
    
    enum KeychainKeys: String, RawRepresentable {
        case apiToken
    }
}
