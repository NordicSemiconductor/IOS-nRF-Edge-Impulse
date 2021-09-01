//
//  NordicError.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/3/21.
//

import Foundation

struct NordicError: LocalizedError {
    
    let description: String
    
    var failureReason: String? { description }
    var errorDescription: String? { description }
}

extension NordicError {
    static let testError = NordicError(description: "This is a Test Error")
}
