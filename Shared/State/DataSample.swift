//
//  DataSample.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/5/21.
//

import Foundation

struct DataSample: Identifiable, Codable {
    
    let id: Int
    let filename: String
}

// MARK: - DataSample.Category

extension DataSample {
    
    enum Category: String, Identifiable, RawRepresentable, CaseIterable {
        case training, testing, anomaly
        
        var id: Int {
            rawValue.hashValue
        }
    }
}
