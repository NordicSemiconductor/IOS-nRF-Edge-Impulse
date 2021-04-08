//
//  WebSocketManager.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 08/04/2021.
//

import Foundation
import Combine

/// Static constants and structures
extension WebSocketManager {
    struct Error: Swift.Error {
        // TODO: Add code and message to error
        static let wrongUrl = Error()
    }
}

class WebSocketManager {
    private let session: URLSession
    private var task: URLSessionWebSocketTask!
    
    init() {
        session = URLSession(configuration: .default)
    }
    
    func connect(to urlString: String) throws {
        guard let url = URL(string: urlString) else {
            throw Error.wrongUrl
        }
        
        task = session.webSocketTask(with: url)
        listen()
    }
    
    func send() {
        
    }
}

/// Private API
extension WebSocketManager {
    private func listen() {
        task.receive { result in
            switch result {
            case .failure(let e):
                // TODO: Handle error
                break
            case .success(let msg):
                // TODO: emit message
                break
            }
        }
    }
}
