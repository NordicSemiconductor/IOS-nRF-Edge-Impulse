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
    private var lastSavedSHA: String? {
        didSet {
            guard let newSHA = lastSavedSHA else { return }
            keychain.set(newSHA, forKey: KeychainKeys.lastSavedSHA.rawValue)
        }
    }
    private var lastUpdateDate: Date? {
        didSet {
            guard let newValue = lastUpdateDate else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            keychain.set(dateFormatter.string(from: newValue), forKey: KeychainKeys.lastUpdateDate.rawValue)
        }
    }
    
    // MARK: - Combine
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        self.lastSavedSHA = keychain.get(KeychainKeys.lastSavedSHA.rawValue)
        if let dateStringValue = keychain.get(KeychainKeys.lastUpdateDate.rawValue) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            self.lastUpdateDate = dateFormatter.date(from: dateStringValue)
        }
        
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
}

// MARK: - Private API

fileprivate extension ResourceData {
    
    private func readResourcesFromDisk() {
        do {
            for resource in Resource.allCases {
                _ = try [UUIDMapping].readFromDocumentsDirectory(fileName: resource.rawValue, andExtension: "json")
            }
        } catch {
            lastSavedSHA = nil
        }
    }
    
    private func downloadFreshResources(withSHA sha: String) {
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
                self.lastSavedSHA = sha
                self.lastUpdateDate = Date()
            }
            .store(in: &cancellables)
    }
}

// MARK: - KeychainKeys

private extension ResourceData {
    
    enum KeychainKeys: String, Codable {
        case lastSavedSHA
        case lastUpdateDate
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
