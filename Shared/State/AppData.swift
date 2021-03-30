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
    @Published var user: User?
    
    @Published var dashboardViewState: DashboardView.ViewState = .empty
    @Published var projects: [Project] = []
    @Published var scanResults: [ScanResult] = []
    
    @Published var selectedTab: Tabs? = .Dashboard
    @Published var serviceUUIDs: [UUIDMapping]
    @Published var characteristicUUIDs: [UUIDMapping]
    @Published var descriptorUUIDs: [UUIDMapping]
    
    // MARK: - Private Properties
    
    private lazy var keychain = KeychainSwift()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        self.serviceUUIDs = [UUIDMapping]()
        self.characteristicUUIDs = [UUIDMapping]()
        self.descriptorUUIDs = [UUIDMapping]()
        
        self.apiToken = keychain.get(KeychainKeys.apiToken.rawValue)
    }
    
    // MARK: - API
    
    var isLoggedIn: Bool { apiToken != nil }
    
    func logout() {
        apiToken = nil
        user = nil
    }
    
    func updateResources() {
        let resourcesToArrayKeyPaths: [Resources: ReferenceWritableKeyPath<AppData, [UUIDMapping]>] = [
            .services: \.serviceUUIDs, .characteristics: \.characteristicUUIDs,
            .descriptors: \.descriptorUUIDs
        ]
        for (resource, arrayKeyPath) in resourcesToArrayKeyPaths {
            guard let request = HTTPRequest.getResource(resource) else { return }
            Network.shared.perform(request, responseType: [UUIDMapping].self)
                .sink(to: arrayKeyPath, in: self, assigningInCaseOfError: [UUIDMapping]())
                .store(in: &cancellables)
        }
    }
}

// MARK: - KeychainKeys

private extension AppData {
    
    enum KeychainKeys: String, RawRepresentable {
        case apiToken
    }
}
