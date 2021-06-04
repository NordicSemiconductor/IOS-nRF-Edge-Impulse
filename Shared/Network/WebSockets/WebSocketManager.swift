//
//  WebSocketManager.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 08/04/2021.
//

import Foundation
import Combine
import os

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

/// Static constants and structures
extension WebSocketManager {
    enum Error: Swift.Error {
        // TODO: Add code and message to error
        case wrongUrl
        case unableToEncodeAsUTF8
        case wsError(Swift.Error)
    }
    
    // TODO: maybe we should get it from DK
    static let address = "wss://remote-mgmt.edgeimpulse.com"
}

class WebSocketManager {
    private let publisher = PassthroughSubject<Data, Error>()
    private let session: URLSession
    private let logger = Logger(category: "WebSocketManager")
    
    private var task: URLSessionWebSocketTask!
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        self.session = URLSession(configuration: .default)
//        super.init()
//        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }
    
    func connect() -> AnyPublisher<Data, Error> {
        self.connect(to: Self.address)
    }
    
    func connect(to urlString: String) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: urlString) else {
            return Result.Publisher(.failure(Error.wrongUrl)).eraseToAnyPublisher()
        }
        
        task = session.webSocketTask(with: url)
        listen()
        task.resume()
        
        return publisher.eraseToAnyPublisher()
    }
    
    func disconnect() {
        task.cancel(with: .normalClosure, reason: nil)
    }
    
    func send<T: Codable>(_ data: T) throws {
        guard let encodedData = try? JSONEncoder().encode(data) else { return }
        try send(encodedData)
    }
    
    func send(_ data: Data) throws {
        guard let s = String(data: data, encoding: .utf8) else {
            throw Error.unableToEncodeAsUTF8
        }
        
        task.send(.string(s)) { [weak self] (error) in
            if let e = error {
                self?.publisher.send(completion: .failure(.wsError(e)))
                self?.logger.error("Send error: \(e.localizedDescription)")
            } 
        }
    }
}

/// Private API
extension WebSocketManager {
    private func listen() {
        task.receive { [weak self] result in
            switch result {
            case .failure(let e):
                self?.publisher.send(completion: .failure(.wsError(e)))
                self?.logger.error("Error: \(e.localizedDescription)")
            case .success(let msg):
                switch msg {
                case .data(let d):
                    self?.publisher.send(d)
                    self?.logger.info("Data received: \(d)")
                case .string(let s):
                    self?.publisher.send(s.data(using: .utf8)!)
                    self?.logger.info("Message received: \(s)")
                @unknown default:
                    break 
                }
            }
        }
    }
}
