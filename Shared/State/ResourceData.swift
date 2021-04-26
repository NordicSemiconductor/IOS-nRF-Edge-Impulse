//
//  ResourceData.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 29/3/21.
//

import Foundation
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
    
    @Published private(set) var status: Status {
        didSet {
            UserDefaults.standard.set(status.rawValue, forKey: UserDefaultKeys.status)
        }
    }
    private(set) var lastSavedSHA: String? {
        didSet {
            guard let newSHA = lastSavedSHA else { return }
            UserDefaults.standard.set(newSHA, forKey: UserDefaultKeys.lastSavedSHA)
        }
    }
    private(set) var lastCheckDateString: String? {
        didSet {
            guard let newValue = lastCheckDateString else { return }
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.lastUpdateDateString)
        }
    }
    
    // MARK: - Combine
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        self.status = Status(rawValue: UserDefaults.standard.object(forKey: UserDefaultKeys.status) as? String ?? "")
            ?? .notAvailable
        self.lastSavedSHA = UserDefaults.standard.object(forKey: UserDefaultKeys.lastSavedSHA) as? String
        self.lastCheckDateString = UserDefaults.standard.object(forKey: UserDefaultKeys.lastUpdateDateString) as? String
        
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
            .sink(receiveCompletion: completionHandler(_:)) { [weak self] response in
                guard let self = self else { return }
                if response.sha != self.lastSavedSHA {
                    self.downloadFreshResources(withSHA: response.sha)
                } else {
                    self.status = .upToDate
                    self.lastCheckDateString = self.newLastCheckDateString()
                }
            }
            .store(in: &cancellables)
    }
    
    func forceUpdate() {
        status = .loading
        guard let statusRequest = HTTPRequest.getResourceStatus() else { return }
        Network.shared.perform(statusRequest, responseType: GitHubStatusResponse.self)
            .sink(receiveCompletion: completionHandler(_:)) { [weak self] response in
                self?.downloadFreshResources(withSHA: response.sha)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private Network API

fileprivate extension ResourceData {
    
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
            .sink(receiveCompletion: completionHandler(_:)) { [weak self] result in
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
                self.lastCheckDateString = self.newLastCheckDateString()
            }
            .store(in: &cancellables)
    }
    
    func completionHandler(_ completion:  Subscribers.Completion<Error>) {
        switch completion {
        case .failure(let error):
            print("Error requesting Resources SHA: \(error.localizedDescription)")
            status = areResourcesAvailableOnDisk()
        default:
            break
        }
    }
    
    func newLastCheckDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: Date())
    }
}

// MARK: Disk

private extension ResourceData {
    
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

// MARK: - UserDefaultKeys

private extension ResourceData {
    
    enum UserDefaultKeys: String, RawRepresentable {
        case status, lastSavedSHA, lastUpdateDateString
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
