//
//  Internet.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation
import Combine
import SwiftUI
import SystemConfiguration
import os

// MARK: - Network

final class Network {
    
    // MARK: - Properties
    
    private lazy var logger = Logger(Self.self)
    
    private lazy var session = URLSession(configuration: .multiPathEnabled)
    private lazy var imageCache = Cache<URL, Image>()
    private lazy var reachability = SCNetworkReachabilityCreateWithName(nil, "www.edgeimpulse.com")
    
    // MARK: - Singleton
    
    public static let shared = Network()
    
    private init() { }
}

// MARK: - API

extension Network {
    
    // MARK: - Reachability
    
    public func isReachable() -> Bool {
        guard let reachability = reachability else {
            logger.error("\(#function): Nil reachability property.")
            return false
        }
        
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)

        let isReachable = flags.contains(.reachable)
        let connectionRequired = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutIntervention = canConnectAutomatically && !flags.contains(.interventionRequired)
        let result = isReachable && (!connectionRequired || canConnectWithoutIntervention)
        logger.debug("\(#function): Result \(result)")
        return isReachable && (!connectionRequired || canConnectWithoutIntervention)
    }
    
    // MARK: - HTTPRequest
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<Data, Error> {
        return session.dataTaskPublisher(for: request)
            .tryMap() { [logger] element -> Data in
                #if DEBUG
                print(element.response)
                #endif
                
                guard let httpResponse = element.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if httpResponse.statusCode == 401 {
                    throw URLError(.userAuthenticationRequired)
                }
                
                guard httpResponse.statusCode == 200 else {
                    if let responseDataAsString = String(data: element.data, encoding: .utf8) {
                        #if DEBUG
                        logger.debug("\(request): \(responseDataAsString)")
                        #endif
                        throw NordicError(description: responseDataAsString)
                    } else {
                        throw URLError(.badServerResponse)
                    }
                }
                return element.data
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func perform<T: Codable>(_ request: HTTPRequest, responseType: T.Type = T.self) -> AnyPublisher<T, Error> {
        return perform(request)
            .flatMap { data -> AnyPublisher<T, Error> in
                let decoder = JSONDecoder()
                if let response = try? decoder.decode(T.self, from: data) {
                    return Just(response).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                do {
                    let errorResponse = try decoder.decode(EdgeImpulseErrorResponse.self, from: data)
                    return Fail(error: errorResponse)
                        .eraseToAnyPublisher()
                } catch (let error) {
                    guard let stringResponse = String(data: data, encoding: .utf8) else {
                        return Fail(error: error)
                            .eraseToAnyPublisher()
                    }
                    if stringResponse.contains("session expired") {
                        return Fail(error: URLError(.userAuthenticationRequired))
                            .eraseToAnyPublisher()
                    } else  {
                        return Fail(error: EdgeImpulseErrorResponse(success: false, error: "Unknown Server Error Received."))
                            .eraseToAnyPublisher()
                    }
                }
            }
            .tryCatch { error -> AnyPublisher<T, Error> in
                if let urlError = error as? URLError, urlError.errorCode == -1200 {
                    return Fail(error: URLError(.appTransportSecurityRequiresSecureConnection))
                        .eraseToAnyPublisher()
                }
                throw error
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Image(s)
    
    public func downloadImage(for url: URL) -> AnyPublisher<Image?, Never> {
        if let cachedImage = imageCache[url] {
            return Just(cachedImage)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .map { response -> Image? in
                let image: Image?
                #if os(OSX)
                guard let nsimage = NSImage(data: response.data) else { return nil }
                image = Image(nsImage: nsimage)
                #elseif os(iOS)
                guard let uiimage = UIImage(data: response.data) else { return nil }
                image = Image(uiImage: uiimage)
                #endif
                return image
            }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .map { [imageCache] image in
                imageCache[url] = image
                return image
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - EdgeImpulseErrorResponse

struct EdgeImpulseErrorResponse: APIResponse, LocalizedError {
    
    let success: Bool
    let error: String?
    
    var errorDescription: String? { error }
    var recoverySuggestion: String? { error }
    var helpAnchor: String? { "Try Postman or ask Roshee for help." }
}
