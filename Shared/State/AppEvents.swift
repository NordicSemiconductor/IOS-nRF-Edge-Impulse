//
//  AppEvents.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 26/4/21.
//

import Foundation
import iOS_Common_Libraries

final class AppEvents: ObservableObject {
    
    // MARK: - Private Properties
    
    @Published var error: ErrorEvent?
    
    // MARK: - Init
    
    static let shared = AppEvents()
    
    private init() {}
}
