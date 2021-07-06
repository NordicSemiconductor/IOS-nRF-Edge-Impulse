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
        case wsClosed(URLSessionWebSocketTask.CloseCode)
        case parseError
    }
    
    enum State {
        case notConnected, connecting, connected
    }
}

class WebSocketManager: NSObject {
    let dataSubject = PassthroughSubject<Result<Data, Swift.Error>, Never>()
    private let logger = Logger(category: String(describing: WebSocketManager.self))
    
    private var session: URLSession!
    private var socketURL: URL!
    private var socketTimeout: TimeInterval!
    private var task: URLSessionWebSocketTask!
    private var cancellables = Set<AnyCancellable>()
    
    private var stateSubject = PassthroughSubject<State, Error>()
    
    func connect(to urlString: String, pingTimeout: TimeInterval = WebSocketManager.PingTime) -> AnyPublisher<State, Swift.Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: Error.wrongUrl).eraseToAnyPublisher()
        }
        
        socketURL = url
        socketTimeout = pingTimeout
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        task = session.webSocketTask(with: socketURL)
        listen()
        task.resume()
        schedulePings()
        
        return stateSubject
            .mapError { $0 as Swift.Error }
            .eraseToAnyPublisher()
    }
    
    func disconnect() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        task.cancel(with: .normalClosure, reason: nil)
        session.finishTasksAndInvalidate()
        
        socketURL = nil
        socketTimeout = nil
        session = nil
    }
    
    func send<T: Codable>(_ data: T) throws {
        guard let encodedData = try? JSONEncoder().encode(data) else { return }
        try send(encodedData)
    }
    
    func send(_ data: Data) throws {
        guard let s = String(data: data, encoding: .utf8) else {
            throw Error.unableToEncodeAsUTF8
        }
        try send(s)
    }
    
    func send(_ string: String) throws {
        task.send(.string(string)) { [weak self] (error) in
            if let e = error {
                self?.dataSubject.send(.failure(Error.wsError(e)))
                self?.logger.error("Send error: \(e.localizedDescription)")
            }
        }
    }
}

// MARK: - Private API

extension WebSocketManager {
    
    fileprivate static let PingTime: TimeInterval = 20.0
    
    private func schedulePings() {
        Timer
            .publish(every: socketTimeout, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.ping()
            }
            .store(in: &cancellables)
    }
    
    private func ping() {
        task.sendPing { [weak self] error in
            guard let self = self else { return }
            switch error {
            case .none:
                self.logger.debug("Successfully pinged WebSocket at \(self.socketURL.absoluteString).")
            case .some(let error):
                self.logger.error("WebSocket \(self.socketURL.absoluteString) ping returned an error: \(error.localizedDescription)")
                self.logger.error("Triggering disconnection due to ping error.")
                self.disconnect()
            }
        }
    }
    
    private func listen() {
        
        task.receive { [weak self] result in
            switch result {
            case .failure(let e):
                self?.dataSubject.send(.failure(e))
                self?.logger.error("Error: \(e.localizedDescription)")
            case .success(let msg):
                switch msg {
                case .data(let d):
                    self?.dataSubject.send(.success(d))
                    self?.logger.info("Data received: \(String(data: d, encoding: .utf8) ?? d.hexEncodedString())")
                case .string(let s):
                    self?.logger.info("Message received: \(s)")
                    if let d = s.data(using: .utf8) {
                        self?.dataSubject.send(.success(d))
                    } else {
                        self?.logger.error("...but not parsed")
                        self?.dataSubject.send(.failure(Error.parseError))
                    }
                @unknown default:
                    self?.logger.info("Something else received received.")
                    break 
                }
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketManager: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        logger.log("Did open web socket with protocol: \(`protocol` ?? "<unknown>")")
        stateSubject.send(.connected)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        if case .normalClosure = closeCode {
            stateSubject.send(completion: .finished)
            logger.info("Web socket was closed")
        } else {
            stateSubject.send(completion: .failure(.wsClosed(closeCode)))
        }
    }
}
