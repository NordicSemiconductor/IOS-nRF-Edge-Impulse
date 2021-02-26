//
//  Request.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 26/2/21.
//

import Foundation

let API_VERSION = 1

// MARK: - Request

protocol Request {
    associatedtype DataType: Codable
    
    var url: URL { get }
    var data: DataType { get }
}

// MARK: - API

extension Request {
    
    func urlRequest() -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonObject = try? JSONEncoder().encode(data) {
            urlRequest.httpBody = String(data: jsonObject, encoding: .utf8)?.data(using: .utf8)
        }
        return urlRequest
    }
}
