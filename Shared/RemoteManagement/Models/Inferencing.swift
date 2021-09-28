//
//  Inferencing.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 28/9/21.
//

import Foundation

// MARK: - Inferencing Request

struct InferencingRequest: Codable {
    
    enum MessageType: String {
        case start = "start-inferencing"
        case stop = "stop-inferencing"
    }
    
    let type: String
    
    init(_ type: MessageType) {
        self.type = type.rawValue
    }
}

// MARK: - Inferencing Response

struct InferencingResponse: Codable {
    
    let type: String
    let ok: Bool
    let error: String?
}

// MARK: - Inferencing Results

struct InferencingResults: Codable {
    
    // MARK: Classification
    
    struct Classification: Codable {
        
        let label: String
        let value: Double
    }
    
    let type: String
    let classification: [Classification]
    let anomaly: String
}

