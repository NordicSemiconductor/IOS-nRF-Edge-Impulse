//
//  AppData.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 1/3/21.
//

import Foundation
import KeychainSwift

final class AppData: ObservableObject {
    
    // MARK: - Private Properties
    
    private lazy var keychain = KeychainSwift()
    
    // MARK: - Init
    
    init() {
        self.apiToken = keychain.get(KeychainKeys.apiToken.rawValue)
    }
    
    // MARK: - Publishers
    
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
    @Published var projectsViewState: ProjectList.ViewState = .empty
    @Published var projects: [Project] = []
    @Published var devices: [Device] = []
    
    @Published var selectedTab: Tabs? = .Dashboard
    
    // MARK: - API
    
    var isLoggedIn: Bool { apiToken != nil }
    
    func logout() {
        apiToken = nil
    }
}

// MARK: - KeychainKeys

private extension AppData {
    
    enum KeychainKeys: String, RawRepresentable {
        case apiToken
    }
}
