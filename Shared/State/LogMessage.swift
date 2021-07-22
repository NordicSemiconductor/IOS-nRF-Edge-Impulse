//
//  LogMessage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/7/21.
//

import Foundation

struct LogMessage: Hashable {
    
    let line: String
    let timestamp = Date()
    
    init(_ line: String) {
        self.line = line
    }
    
    init(_ message: SocketIOJobMessage) {
        self.line = message.message
    }
    
    init(_ error: Error) {
        self.line = "Error: \(error.localizedDescription)"
    }
}
