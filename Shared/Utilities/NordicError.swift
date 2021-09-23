//
//  NordicError.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/3/21.
//

import Foundation

struct NordicError: LocalizedError, Hashable {
    
    let description: String
    
    var failureReason: String? { description }
    var errorDescription: String? { description }
}

extension NordicError {
    
    static let testError = NordicError(description: "This is a Test Error")
    
    static let deviceWebSocketDisconnectedError = NordicError(description: "Lost Device Remote Management connection. Disconnecting from device.")
}
