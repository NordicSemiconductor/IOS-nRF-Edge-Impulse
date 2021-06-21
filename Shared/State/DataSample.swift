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
    let category: Category
    let label: String
    let totalLengthMs: Double
    
    func totalLengthInSeconds() -> String {
        let double = Measurement(value: totalLengthMs, unit: UnitDuration.milliseconds)
            .converted(to: .seconds).value
        return String(format: "%.2fs", double)
    }
}

// MARK: - DataSample.Category

extension DataSample {
    
    enum Category: String, Identifiable, Codable, RawRepresentable, CaseIterable {
        case training, testing
        
        var id: Int {
            rawValue.hashValue
        }
        
        var symbolName: String {
            switch self {
            case .training:
                return "highlighter"
            case .testing:
                return "pencil.and.outline"
            }
        }
        
        static let userVisible: [DataSample.Category] = [
            .training, .testing
        ]
    }
}
