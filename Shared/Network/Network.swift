//
//  Internet.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation
import Combine
import SwiftUI
#if os(OSX)
import AppKit
#endif

// MARK: - Network

final class Network {
    
    // MARK: - Properties
    
    public lazy var session = URLSession(configuration: .default)
    
    // MARK: - Singleton
    
    public static let shared = Network()
    
    private init() { }
}

// MARK: - API

extension Network {
    
    public func perform<T: Codable>(_ request: HTTPRequest, responseType: T.Type = T.self) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: request)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if httpResponse.statusCode == 401 {
                    throw URLError(.userAuthenticationRequired)
                }
                return element.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public func downloadImage(for url: URL) -> AnyPublisher<Image?, Never> {
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
            .eraseToAnyPublisher()
    }
}
