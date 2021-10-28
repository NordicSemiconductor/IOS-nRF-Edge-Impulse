//
//  URLSession.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 28/10/21.
//

import Foundation

// MARK: - URLSessionConfiguration

extension URLSessionConfiguration {
    
    static let multiPathEnabled: URLSessionConfiguration = {
        var multiPathEnabledConfiguration: URLSessionConfiguration = .default
        #if os(iOS)
        multiPathEnabledConfiguration.multipathServiceType = .interactive
        #endif
        return multiPathEnabledConfiguration
    }()
}
