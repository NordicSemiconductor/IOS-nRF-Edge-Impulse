//
//  WebSocketManager.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 08/04/2021.
//

import Foundation
import Combine
import os

/// Static constants and structures
extension WebSocketManager {
    enum Error: Swift.Error {
        // TODO: Add code and message to error
        case wrongUrl
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
    
    func send(_ data: Data) {
        
        
        task.send(.data(data)) { [weak self] (error) in
            if let e = error {
                self?.publisher.send(completion: .failure(.wsError(e)))
                self?.logger.error("Send error: \(e.localizedDescription)")
            } 
            
            #warning("remove test code")
            self?.publisher.send(WSHelloResponse.success.data)
            
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
/*
extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        logger.info("Web Socket Connection was opened")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        logger.info("Web socket connection was closed due to \(closeCode.rawValue)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        let s = #function
        logger.debug("URLSessionWebSocketDelegate: \(s)")
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        let s = #function
        logger.debug("URLSessionWebSocketDelegate: \(s)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        let s = #function
        logger.debug("URLSessionWebSocketDelegate: \(s)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let s = #function
        logger.debug("URLSessionWebSocketDelegate: \(s)")
        
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        let s = #function
        logger.debug("URLSessionWebSocketDelegate: \(s)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let s = #function
        logger.debug("URLSessionWebSocketDelegate: \(s)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        let s = #function
        logger.debug("URLSessionWebSocketDelegate: \(s)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        let s = #function
        logger.debug("URLSessionWebSocketDelegate: \(s)")
    }
}
*/
