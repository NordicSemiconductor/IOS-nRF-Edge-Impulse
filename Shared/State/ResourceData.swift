//
//  ResourceData.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 29/3/21.
//

import Foundation
import Combine

final class ResourceData: ObservableObject {
    
    // MARK: - Private
    
    private var serviceUUIDs: [UUIDMapping]
    private var characteristicUUIDs: [UUIDMapping]
    private var descriptorUUIDs: [UUIDMapping]
    private var cancellables: Set<AnyCancellable>
    
    // MARK: - Init
    
    init() {
        self.serviceUUIDs = [UUIDMapping]()
        self.characteristicUUIDs = [UUIDMapping]()
        self.descriptorUUIDs = [UUIDMapping]()
        self.cancellables = Set<AnyCancellable>()
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
        let resourcesToArrayKeyPaths: [Resource: ReferenceWritableKeyPath<ResourceData, [UUIDMapping]>] = [
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

// MARK: - Resource

enum Resource: String, Codable {
    
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
