//
//  ResourceData.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 29/3/21.
//

import Foundation
import KeychainSwift
import Combine

final class ResourceData: ObservableObject {
    
    // MARK: - Private
    
    private var lastSavedSHA: String? {
        didSet {
            guard let newSHA = lastSavedSHA else { return }
            keychain.set(newSHA, forKey: KeychainKeys.lastSavedSHA.rawValue)
        }
    }
    private var serviceUUIDs: [UUIDMapping]
    private var characteristicUUIDs: [UUIDMapping]
    private var descriptorUUIDs: [UUIDMapping]
    
    private var keychain = KeychainSwift()
    private lazy var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        self.lastSavedSHA = keychain.get(KeychainKeys.lastSavedSHA.rawValue)
        self.serviceUUIDs = [UUIDMapping]()
        self.characteristicUUIDs = [UUIDMapping]()
        self.descriptorUUIDs = [UUIDMapping]()
    }
    
    // MARK: - API
    
    subscript(_ resource: Resource, uuid: UUID) -> UUIDMapping? {
        self[resource, uuid.uuidString]
    }
    
    subscript(_ resource: Resource, uuidString: String) -> UUIDMapping? {
        let arrayKeyPath: KeyPath<ResourceData, [UUIDMapping]>
        switch resource {
        case .services:
            arrayKeyPath = \.serviceUUIDs
        case .characteristics:
            arrayKeyPath = \.characteristicUUIDs
        case .descriptors:
            arrayKeyPath = \.descriptorUUIDs
        }
        return self[keyPath: arrayKeyPath].first(where: { $0.uuid == uuidString })
    }
    
    func update() {
        guard let statusRequest = HTTPRequest.getResourceStatus() else { return }
        Network.shared.perform(statusRequest, responseType: GitHubStatusResponse.self)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error requesting Resources SHA: \(error.localizedDescription)")
                default:
                    break
                }
            } receiveValue: { [weak self] response in
                guard let self = self, response.sha != self.lastSavedSHA else { return }
                self.downloadFreshResources(withSHA: response.sha)
            }
            .store(in: &cancellables)
    }
    
    func downloadFreshResources(withSHA sha: String) {
        let resourcesToArrayKeyPaths: [Resource: ReferenceWritableKeyPath<ResourceData, [UUIDMapping]>] = [
            .services: \.serviceUUIDs, .characteristics: \.characteristicUUIDs,
            .descriptors: \.descriptorUUIDs
        ]
        
        let requestPublishers = Resource.allCases.compactMap { (resource) -> AnyPublisher<(Resource, [UUIDMapping]), Error>? in
            guard let request = HTTPRequest.getResource(resource) else { return nil }
            return Network.shared.perform(request, responseType: [UUIDMapping].self)
                .map { (resource, $0) }
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(requestPublishers)
            .collect()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("There was an error downloading all Resources: \(error.localizedDescription)")
                default:
                    break
                }
            } receiveValue: { [weak self] result in
                guard let self = self else { return }
                for mapping in result {
                    guard let arrayKeyPath = resourcesToArrayKeyPaths[mapping.0] else { return }
                    self[keyPath: arrayKeyPath] = mapping.1
                }
                // TODO: Save to Disk
                
//                self.lastSavedSHA = sha
            }
            .store(in: &cancellables)
    }
}

// MARK: - KeychainKeys

private extension ResourceData {
    
    enum KeychainKeys: String, Codable {
        case lastSavedSHA
    }
}

// MARK: - Resource

enum Resource: String, Codable, CaseIterable {
    
    case services
    case characteristics
    case descriptors
}

// MARK: - UUIDMapping

struct UUIDMapping: Identifiable, Codable {
    
    var id: String { uuid }
    
    let uuid: String
    let name: String
}
