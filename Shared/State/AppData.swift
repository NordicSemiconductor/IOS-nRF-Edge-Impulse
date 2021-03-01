//
//  AppData.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 1/3/21.
//

import Foundation

final class AppData: ObservableObject {
    
    @Published var apiToken: String?
    
    init() {
        self.apiToken = nil
    }
}
