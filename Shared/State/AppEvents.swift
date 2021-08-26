//
//  AppEvents.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 26/4/21.
//

import Foundation
import Combine

final class AppEvents: ObservableObject {
    
    // MARK: - Private Properties
    
    @Published var error: ErrorEvent?
    
    // MARK: - Init
    
    static let shared = AppEvents()
    
    private init() {}
}

// MARK: - ErrorEvent

struct ErrorEvent: Error, Identifiable, Hashable {
    
    let title: String
    let localizedDescription: String
    
    // MARK: Init
    
    init(_ error: Error) {
        self.init(title: "Error", localizedDescription: error.localizedDescription)
    }
    
    init(title: String, localizedDescription: String) {
        self.title = title
        self.localizedDescription = localizedDescription
    }
    
    var id: Int {
        hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(localizedDescription)
    }
}
