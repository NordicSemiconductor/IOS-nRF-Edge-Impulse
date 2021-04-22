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
    
    // MARK: - UUID Arrays
    
    private var serviceUUIDs: [UUIDMapping]
    private var characteristicUUIDs: [UUIDMapping]
    private var descriptorUUIDs: [UUIDMapping]
    
    private lazy var resourcesToArrayKeyPaths: [Resource: ReferenceWritableKeyPath<ResourceData, [UUIDMapping]>] = [
        .services: \.serviceUUIDs, .characteristics: \.characteristicUUIDs,
        .descriptors: \.descriptorUUIDs
    ]
    
    // MARK: - Keychain
    
    private var keychain = KeychainSwift()
    @Published private(set) var status: Status {
        didSet {
            keychain.set(status.rawValue, forKey: KeychainKeys.status.rawValue)
        }
    }
    private(set) var lastSavedSHA: String? {
        didSet {
            guard let newSHA = lastSavedSHA else { return }
            keychain.set(newSHA, forKey: KeychainKeys.lastSavedSHA.rawValue)
        }
    }
    private(set) var lastUpdateDateString: String? {
        didSet {
            guard let newValue = lastUpdateDateString else { return }
            keychain.set(newValue, forKey: KeychainKeys.lastUpdateDateString.rawValue)
        }
    }
    
    // MARK: - Combine
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        self.status = Status(rawValue: keychain.get(KeychainKeys.status.rawValue) ?? "") ?? .notAvailable
        self.lastSavedSHA = keychain.get(KeychainKeys.lastSavedSHA.rawValue)
        self.lastUpdateDateString = keychain.get(KeychainKeys.lastUpdateDateString.rawValue)
        
        self.serviceUUIDs = [UUIDMapping]()
        self.characteristicUUIDs = [UUIDMapping]()
        self.descriptorUUIDs = [UUIDMapping]()
    }
    
    // MARK: - Public API
    
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
    
    func load() {
        readResourcesFromDisk()
        
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
                guard let self = self else { return }
                if response.sha != self.lastSavedSHA {
                    self.downloadFreshResources(withSHA: response.sha)
                }
            }
            .store(in: &cancellables)
    }
    
    func forceUpdate() {
        status = .loading
        guard let statusRequest = HTTPRequest.getResourceStatus() else { return }
        Network.shared.perform(statusRequest, responseType: GitHubStatusResponse.self)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Error requesting Resources SHA: \(error.localizedDescription)")
                    if let resourcesOnDiskStatus = self?.areResourcesAvailableOnDisk() {
                        self?.status = resourcesOnDiskStatus
                    }
                default:
                    break
                }
            } receiveValue: { [weak self] response in
                self?.downloadFreshResources(withSHA: response.sha)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private API

fileprivate extension ResourceData {
    
    private func readResourcesFromDisk() {
        do {
            for resource in Resource.allCases {
                let arrayKeypath: ReferenceWritableKeyPath<ResourceData, [UUIDMapping]>! = resourcesToArrayKeyPaths[resource]
                self[keyPath: arrayKeypath] = try [UUIDMapping].readFromDocumentsDirectory(fileName: resource.rawValue, andExtension: "json")
            }
            status = .available
        } catch {
            status = .notAvailable
            lastSavedSHA = nil
        }
    }
    
    private func downloadFreshResources(withSHA sha: String) {
        self.status = .loading
        let requestPublishers = Resource.allCases.compactMap { (resource) -> AnyPublisher<(Resource, [UUIDMapping]), Error>? in
            guard let request = HTTPRequest.getResource(resource) else { return nil }
            return Network.shared.perform(request, responseType: [UUIDMapping].self)
                .map { (resource, $0) }
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(requestPublishers)
            .collect()
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("There was an error downloading all Resources: \(error.localizedDescription)")
                    if let resourcesOnDiskStatus = self?.areResourcesAvailableOnDisk() {
                        self?.status = resourcesOnDiskStatus
                    }
                default:
                    break
                }
            } receiveValue: { [weak self] result in
                guard let self = self else { return }
                var encounteredError = false
                for mapping in result {
                    guard let arrayKeyPath = self.resourcesToArrayKeyPaths[mapping.0] else { continue }
                    self[keyPath: arrayKeyPath] = mapping.1
                    
                    do {
                        try mapping.1.writeToDocumentsDirectory(fileName: mapping.0.rawValue, andExtension: "json")
                    } catch {
                        encounteredError = true
                        continue
                    }
                }
                guard !encounteredError else { return }
                self.status = .upToDate
                self.lastSavedSHA = sha
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                self.lastUpdateDateString = dateFormatter.string(from: Date())
            }
            .store(in: &cancellables)
    }
    
    func areResourcesAvailableOnDisk() -> Status {
        for resource in Resource.allCases {
            guard let resourceKeypath = resourcesToArrayKeyPaths[resource],
                  self[keyPath: resourceKeypath].hasItems else {
                return .notAvailable
            }
        }
        return .available
    }
}

// MARK: - KeychainKeys

private extension ResourceData {
    
    enum KeychainKeys: String, Codable {
        case status
        case lastSavedSHA
        case lastUpdateDateString
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
