//
//  WebSocketManager.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 08/04/2021.
//

import Foundation
import Combine
import os
import iOS_Common_Libraries

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

// MARK: - WebSocketManager

final class WebSocketManager: NSObject {
    
    /**
     Subscribe to listen to all data received via WebSocket.
     */
    let dataSubject = PassthroughSubject<Result<Data, Swift.Error>, Never>()
    private let logger = Logger(category: String(describing: WebSocketManager.self))
    
    private var session: URLSession!
    private var pingConfiguration = PingConfiguration()
    private var task: URLSessionWebSocketTask!
    private var cancellables = Set<AnyCancellable>()
    
    private var stateSubject = PassthroughSubject<State, Error>()
    
    /**
     - Returns: Subject/Publisher reporting status changes (connected, disconnected etc).
     */
    func connect(to urlString: String, using pingConfiguration: PingConfiguration) -> AnyPublisher<State, Swift.Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: Error.wrongUrl).eraseToAnyPublisher()
        }
        
        logger.debug(#function)
        self.pingConfiguration = pingConfiguration
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        task = session.webSocketTask(with: url)
        task.resume()
        return stateSubject
            .mapError { $0 as Swift.Error }
            .eraseToAnyPublisher()
    }
    
    func disconnect() {
        logger.debug(#function)
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        if let task = task {
            task.cancel(with: .normalClosure, reason: nil)
        }
        if let session = session {
            session.finishTasksAndInvalidate()
        }
        
        session = nil
    }
    
    func send<T: Codable>(_ data: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        guard let encodedData = try? encoder.encode(data) else { return }
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
            guard let e = error as NSError? else { return }
            self?.logger.error("Encountered Error: \(e.localizedDescription) sending \(string)")
            self?.dataSubject.send(.failure(Error.wsError(e)))
        }
    }
}

// MARK: - Private API

extension WebSocketManager {
    
    private func listen() {
        task.receive { [weak self] result in
            switch result {
            case .failure(let e):
                if let nsError = e as NSError? {
                    self?.logger.error("Error (Code \(nsError.code)): \(e.localizedDescription)")
                } else {
                    self?.logger.error("Error: \(e.localizedDescription)")
                }
                
                self?.dataSubject.send(.failure(e))
                self?.stateSubject.send(completion: .failure(.wsError(e)))
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
                self?.listen()
            }
        }
        logger.debug("Listener Attached.")
    }
    
    private func schedulePings() {
        let timeout = pingConfiguration.timeout
        Timer
            .publish(every: timeout, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if let pingData = self?.pingConfiguration.data {
                    self?.logger.info("Sending Ping Data: \(pingData.hexEncodedString())")
                    try? self?.send(pingData)
                }
                self?.ping()
            }
            .store(in: &cancellables)
    }
    
    private func ping() {
        task.sendPing { [weak self] error in
            guard let self = self, let socketURLString = self.task.currentRequest?.url?.absoluteString else { return }
            switch error {
            case .none:
                self.logger.debug("Successfully pinged WebSocket at \(socketURLString).")
            case .some(let error):
                self.logger.error("WebSocket \(socketURLString) ping returned an error: \(error.localizedDescription)")
                self.stateSubject.send(completion: .failure(.wsError(error)))
                self.logger.error("Triggering disconnection due to ping error.")
                self.disconnect()
            }
        }
    }
}

// MARK: - PingConfiguration

extension WebSocketManager {
    
    struct PingConfiguration {
        
        static let PingTime: TimeInterval = 20.0
        
        let timeout: TimeInterval
        let data: Data?
     
        init(timeout: TimeInterval = PingTime, data: Data? = nil) {
            self.timeout = timeout
            self.data = data
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketManager: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        logger.log("Did open web socket with protocol: \(`protocol` ?? "<unknown>")")
        listen()
        schedulePings()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.stateSubject.send(.connected)
        }
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
